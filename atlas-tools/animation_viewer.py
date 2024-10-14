import sys
import os
import re
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QFileSystemModel, QTreeView,
    QListWidget, QSplitter, QStatusBar, QFileDialog, QPushButton,
    QGraphicsView, QGraphicsScene, QGraphicsPixmapItem, QVBoxLayout, QWidget
)
from PyQt5.QtGui import QPixmap, QImage
from PyQt5.QtCore import Qt, QModelIndex, QRectF

from PIL import Image, ImageDraw

class ImageViewer(QGraphicsView):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._zoom = 0
        self._empty = True
        self._scene = QGraphicsScene(self)
        self._photo = QGraphicsPixmapItem()
        self._scene.addItem(self._photo)
        self.setScene(self._scene)
        self.setTransformationAnchor(QGraphicsView.AnchorUnderMouse)
        self.setResizeAnchor(QGraphicsView.AnchorUnderMouse)
        self.setViewportUpdateMode(QGraphicsView.SmartViewportUpdate)
        self.setDragMode(QGraphicsView.NoDrag)  # Disable hand drag mode initially
        self._parent = parent

        # Variables to store the state
        self._zoomStack = []
        self._transformStack = []

    def hasPhoto(self):
        return not self._empty

    def fitInView(self, scale=True):
        rect = QRectF(self._photo.pixmap().rect())
        if not rect.isNull():
            self.setSceneRect(rect)
            if self.hasPhoto() and scale:
                unity = self.transform().mapRect(QRectF(0, 0, 1, 1))
                self.scale(1 / unity.width(), 1 / unity.height())
                viewrect = self.viewport().rect()
                scenerect = self.transform().mapRect(rect)
                factor = min(viewrect.width() / scenerect.width(),
                             viewrect.height() / scenerect.height())
                self.scale(factor, factor)
                self._zoom = 0

    def setPhoto(self, pixmap=None, preserve_transform=False):
        if preserve_transform:
            # Store current transformation
            transform = self.transform()
        else:
            self._zoom = 0

        if pixmap and not pixmap.isNull():
            self._empty = False
            self._photo.setPixmap(pixmap)
        else:
            self._empty = True
            self._photo.setPixmap(QPixmap())

        self.fitInView(scale=not preserve_transform)

        if preserve_transform:
            # Restore transformation
            self.setTransform(transform)

    def wheelEvent(self, event):
        if self.hasPhoto():
            factor = 1.25 ** (event.angleDelta().y() / 240)
            self.scale(factor, factor)
            self._zoom += event.angleDelta().y() / 240
        else:
            super().wheelEvent(event)

    def mousePressEvent(self, event):
        # Enable drag mode only when the mouse is pressed
        if event.button() == Qt.LeftButton and self.hasPhoto():
            self.setDragMode(QGraphicsView.ScrollHandDrag)
        super().mousePressEvent(event)

    def mouseReleaseEvent(self, event):
        # Disable drag mode and reset cursor to pointer when releasing the mouse
        if event.button() == Qt.LeftButton and self.hasPhoto():
            self.setDragMode(QGraphicsView.NoDrag)
        super().mouseReleaseEvent(event)

    def mouseMoveEvent(self, event):
        if self._parent:
            # Map the mouse position to scene coordinates
            scene_pos = self.mapToScene(event.pos())
            x = int(scene_pos.x())
            y = int(scene_pos.y())
            self._parent.updateStatusBar(f"X: {x}, Y: {y}")
        # Set cursor to pointer when moving over the image
        if self.hasPhoto():
            self.viewport().setCursor(Qt.ArrowCursor)
        super().mouseMoveEvent(event)

    def leaveEvent(self, event):
        if self._parent:
            self._parent.updateStatusBar("")
        super().leaveEvent(event)

class AnimationViewer(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('FF9 Animation Viewer')
        self.resize(1200, 800)

        # Initialize variables
        self.current_dir = ''
        self.unit_anime_file = ''
        self.unit_cgg_file = ''
        self.unit_id = ''
        self.cgs_files = {}
        self.frames = []
        self.frame_indices = []
        self.image_path = ''

        # Initialize UI components
        self.initUI()

    def initUI(self):
        # Main splitter to divide the window horizontally
        splitter = QSplitter(Qt.Horizontal)

        # Left side: Vertical splitter for directory, animations, and frames
        leftSplitter = QSplitter(Qt.Vertical)

        # Directory tree
        self.dirModel = QFileSystemModel()
        self.dirModel.setRootPath('')
        self.treeView = QTreeView()
        self.treeView.setModel(self.dirModel)
        self.treeView.setRootIndex(self.dirModel.index(''))
        self.treeView.clicked.connect(self.onTreeClicked)
        leftSplitter.addWidget(self.treeView)

        # List of animations
        self.animationList = QListWidget()
        self.animationList.clicked.connect(self.onAnimationSelected)
        leftSplitter.addWidget(self.animationList)

        # List of frames
        self.frameList = QListWidget()
        self.frameList.clicked.connect(self.onFrameSelected)
        leftSplitter.addWidget(self.frameList)

        splitter.addWidget(leftSplitter)

        # Right side: Image viewer with zoom and pan
        self.imageViewer = ImageViewer(self)
        splitter.addWidget(self.imageViewer)

        # Set splitter as central widget
        self.setCentralWidget(splitter)

        # Set initial sizes for leftSplitter (adjust as needed)
        leftSplitter.setSizes([200, 100, 100])

        # Set initial sizes for the main splitter
        splitter.setSizes([300, 900])  # Left panel width, right panel width

        # Menu bar actions
        self.createMenu()

        # Status bar for cursor coordinates
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)

    def createMenu(self):
        openDirAction = QPushButton('Open Directory')
        openDirAction.clicked.connect(self.openDirectory)
        toolbar = self.addToolBar('Toolbar')
        toolbar.addWidget(openDirAction)

    def openDirectory(self):
        dirPath = QFileDialog.getExistingDirectory(self, 'Select Directory', '')
        if dirPath:
            self.treeView.setRootIndex(self.dirModel.index(dirPath))

    def onTreeClicked(self, index: QModelIndex):
        dir_path = self.dirModel.filePath(index)
        if os.path.isdir(dir_path):
            # Check for 'unit_anime_<unit_id>.png' and 'unit_cgg_<unit_id>.csv'
            contents = os.listdir(dir_path)
            unit_anime_files = [f for f in contents if f.startswith('unit_anime_') and f.endswith('.png')]
            unit_cgg_files = [f for f in contents if f.startswith('unit_cgg_') and f.endswith('.csv')]
            if unit_anime_files and unit_cgg_files:
                self.current_dir = dir_path
                self.unit_anime_file = unit_anime_files[0]
                self.unit_cgg_file = unit_cgg_files[0]
                self.unit_id = self.unit_anime_file.split('_')[-1].split('.')[0]
                self.listAnimations()
                # Display the image immediately
                image_path = os.path.join(self.current_dir, self.unit_anime_file)
                self.image_path = image_path  # Store for later use
                pixmap = QPixmap(image_path)
                self.imageViewer.setPhoto(pixmap)
            else:
                # Clear the image viewer if no valid files are found
                self.imageViewer.setPhoto(None)

    def listAnimations(self):
        self.animationList.clear()
        self.frameList.clear()
        contents = os.listdir(self.current_dir)
        cgs_files = [f for f in contents if f.startswith('unit_') and f.endswith(f'_cgs_{self.unit_id}.csv')]
        animation_names = []
        for f in cgs_files:
            # Use regular expression to extract the animation name
            match = re.match(r'unit_(.+)_cgs_\d+\.csv', f)
            if match:
                animation_name = match.group(1)
                animation_names.append(animation_name)
        self.cgs_files = dict(zip(animation_names, cgs_files))
        self.animationList.addItems(animation_names)

    def onAnimationSelected(self, index):
        animation_name = self.animationList.currentItem().text()
        cgs_file = self.cgs_files[animation_name]
        # Paths to the required files
        cgg_file_path = os.path.join(self.current_dir, self.unit_cgg_file)
        cgs_file_path = os.path.join(self.current_dir, cgs_file)
        image_path = self.image_path  # Use stored image path

        # Parse the files
        self.frames = parse_cgg_file(cgg_file_path)
        self.frame_indices = parse_cgs_file(cgs_file_path)

        # Populate the frame list
        self.frameList.clear()
        for i, frame_index in enumerate(self.frame_indices):
            self.frameList.addItem(f"Frame {i + 1} (CGG line {frame_index + 1})")

        # Show the image with all frames highlighted initially
        used_rectangles = []
        for frame_index in self.frame_indices:
            if frame_index < len(self.frames):
                parts = self.frames[frame_index]
                for part_index, rect in enumerate(parts):
                    used_rectangles.append({
                        'imgX': rect['imgX'],
                        'imgY': rect['imgY'],
                        'imgWidth': rect['imgWidth'],
                        'imgHeight': rect['imgHeight'],
                        'frame_index': frame_index,   # Line number in CGG
                        'part_index': part_index      # Part number in this frame
                    })

        # Highlight all used areas across frames
        highlighted_image = highlight_used_areas(image_path, used_rectangles)

        # Convert to QImage and display
        qimage = pil_image_to_qimage(highlighted_image)
        pixmap = QPixmap.fromImage(qimage)

        # Set the photo without resetting zoom and position
        self.imageViewer.setPhoto(pixmap, preserve_transform=True)

    def onFrameSelected(self, index):
        frame_list_index = self.frameList.currentRow()
        frame_index = self.frame_indices[frame_list_index]
        # Get the corresponding frame from self.frames
        if frame_index < len(self.frames):
            parts = self.frames[frame_index]
            # Collect rectangles with part indices
            used_rectangles = []
            for part_index, rect in enumerate(parts):
                used_rectangles.append({
                    'imgX': rect['imgX'],
                    'imgY': rect['imgY'],
                    'imgWidth': rect['imgWidth'],
                    'imgHeight': rect['imgHeight'],
                    'frame_index': frame_index,   # Line number in CGG
                    'part_index': part_index      # Part number in this frame
                })
            # Highlight used areas for this frame
            highlighted_image = highlight_used_areas(self.image_path, used_rectangles)
            # Convert to QImage and display
            qimage = pil_image_to_qimage(highlighted_image)
            pixmap = QPixmap.fromImage(qimage)

            # Set the photo without resetting zoom and position
            self.imageViewer.setPhoto(pixmap, preserve_transform=True)

    def updateStatusBar(self, message):
        self.statusBar.showMessage(message)

def parse_cgg_file(cgg_file_path):
    frames = []
    with open(cgg_file_path, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
        for line_number, line in enumerate(lines):
            params = line.split(',')[:-1]
            if len(params) < 2:
                continue
            anchor = int(params[0])
            count = int(params[1])
            rest = params[2:]
            parts = []
            for i in range(count):
                offset = i * 11
                config = rest[offset:offset + 11]
                if len(config) < 11:
                    continue
                (
                    xPos, yPos, nextType, blendMode, opacity,
                    rotate, imgX, imgY, imgWidth, imgHeight, pageID
                ) = map(int, config)
                parts.append({
                    'xPos': xPos,
                    'yPos': yPos,
                    'imgX': imgX,
                    'imgY': imgY,
                    'imgWidth': imgWidth,
                    'imgHeight': imgHeight
                })
            frames.append(parts)
    return frames

def parse_cgs_file(cgs_file_path):
    frame_indices = []
    with open(cgs_file_path, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
        for line in lines:
            params = line.split(',')[:-1]
            if len(params) < 1:
                continue
            frame_index = int(params[0])
            frame_indices.append(frame_index)
    return frame_indices

def highlight_used_areas(image_path, rectangles):
    # Open the image
    image = Image.open(image_path).convert('RGBA')
    overlay = Image.new('RGBA', image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    for rect in rectangles:
        imgX = rect['imgX']
        imgY = rect['imgY']
        imgWidth = rect['imgWidth']
        imgHeight = rect['imgHeight']
        frame_index = rect['frame_index'] + 1  # Convert to 1-based indexing
        part_index = rect['part_index'] + 1    # Convert to 1-based indexing

        # Semi-transparent green overlay for the rectangle
        draw.rectangle(
            [(imgX, imgY), (imgX + imgWidth, imgY + imgHeight)],
            fill=(0, 255, 0, 100)  # Green color
        )

        # Draw text showing "frame_index, part_index"
        draw.text((imgX + 5, imgY + 5), f"{frame_index}\n{part_index}", fill=(255, 255, 255, 255))  # White text

    # Composite the overlay onto the original image
    highlighted_image = Image.alpha_composite(image, overlay)
    return highlighted_image

def pil_image_to_qimage(pil_image):
    # Convert PIL Image to QImage
    pil_image = pil_image.convert("RGBA")
    data = pil_image.tobytes("raw", "RGBA")
    qimage = QImage(data, pil_image.width, pil_image.height, QImage.Format_RGBA8888)
    return qimage

if __name__ == '__main__':
    app = QApplication(sys.argv)
    viewer = AnimationViewer()
    viewer.show()
    sys.exit(app.exec_())
