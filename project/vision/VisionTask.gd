# FILEPATH: /home/macisajt/Downloads/GDMP-demo/project/vision/VisionTask.gd

# This script defines the VisionTask class, which extends the Control class.
# It is responsible for handling vision-related tasks such as loading images and videos, opening the camera, and processing frames.
# The class contains various member variables and methods for initializing the task, processing different types of frames, and managing the camera.

class_name VisionTask
extends Control

# The path to the main scene file.
var main_scene := preload("res://Main.tscn")

# The running mode of the task. Default is set to MediaPipeTask.RUNNING_MODE_IMAGE.
var running_mode := MediaPipeTask.RUNNING_MODE_IMAGE

# The delegate for the task. Default is set to MediaPipeTaskBaseOptions.DELEGATE_CPU.
var delegate := MediaPipeTaskBaseOptions.DELEGATE_CPU

# The camera helper instance for managing camera operations.
var camera_helper := MediaPipeCameraHelper.new()

# The onready variables for accessing UI elements.
@onready var image_view: TextureRect = $VBoxContainer/Image
@onready var video_player: VideoStreamPlayer = $Video
@onready var btn_back: Button = $VBoxContainer/Title/Back
@onready var btn_load_image: Button = $VBoxContainer/Buttons/LoadImage
@onready var btn_load_video: Button = $VBoxContainer/Buttons/LoadVideo
@onready var btn_open_camera: Button = $VBoxContainer/Buttons/OpenCamera
@onready var image_file_dialog: FileDialog = $ImageFileDialog
@onready var video_file_dialog: FileDialog = $VideoFileDialog
@onready var permission_dialog: AcceptDialog = $PermissionDialog

# Called when the script instance is ready.
func _ready():
	# Connect button signals to their respective functions.
	btn_back.pressed.connect(self._back)
	btn_load_image.pressed.connect(image_file_dialog.popup_centered_ratio)
	btn_load_video.pressed.connect(video_file_dialog.popup_centered_ratio)
	btn_open_camera.pressed.connect(self._open_camera)

	# Connect file dialog signals to their respective functions.
	image_file_dialog.file_selected.connect(self._load_image)
	image_file_dialog.root_subfolder = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	video_file_dialog.file_selected.connect(self._load_video)
	video_file_dialog.root_subfolder = OS.get_system_dir(OS.SYSTEM_DIR_MOVIES)

	# Connect camera helper signals to their respective functions.
	camera_helper.permission_result.connect(self._permission_result)
	camera_helper.new_frame.connect(self._camera_frame)

	# Initialize GPU resources if running on Android.
	if OS.get_name() == "Android":
		var gpu_resources := MediaPipeGPUResources.new()
		camera_helper.set_gpu_resources(gpu_resources)

	# Initialize the task.
	init_task()

# Called every frame.
func _process(_delta: float) -> void:
	# Process video frames if the video player is playing.
	if video_player.is_playing():
		var texture := video_player.get_video_texture()
		if texture:
			var image := texture.get_image()
			if image:
				# If the running mode is not set to MediaPipeTask.RUNNING_MODE_VIDEO, update the running mode and initialize the task.
				if not running_mode == MediaPipeTask.RUNNINE_MODE_VIDEO:
					running_mode = MediaPipeTask.RUNNINE_MODE_VIDEO
					init_task()
				process_video_frame(image, Time.get_ticks_msec())

# Called when the back button is pressed.
func _back() -> void:
	# Reset the task and change the scene to the main scene.
	reset()
	get_tree().change_scene_to_packed(main_scene)

# Called when an image file is selected.
func _load_image(path: String) -> void:
	# Reset the task and update the running mode if necessary.
	reset()
	if not running_mode == MediaPipeTask.RUNNING_MODE_IMAGE:
		running_mode = MediaPipeTask.RUNNING_MODE_IMAGE
		init_task()
	var image := Image.load_from_file(path)
	process_image_frame(image)

# Called when a video file is selected.
func _load_video(path: String) -> void:
	# Reset the task and load the video file into the video player.
	reset()
	var stream: VideoStream = load(path)
	video_player.stream = stream
	video_player.play()

# Called when the open camera button is pressed.
func _open_camera() -> void:
	# Check camera permission and start the camera if granted, otherwise request permission.
	if camera_helper.permission_granted():
		start_camera()
	else:
		camera_helper.request_permission()

# Called when the camera permission result is received.
func _permission_result(granted: bool) -> void:
	# Start the camera if permission is granted, otherwise show a permission dialog.
	if granted:
		start_camera()
	else:
		permission_dialog.popup_centered()

# Called when a camera frame is received.
func _camera_frame(image: MediaPipeImage) -> void:
	# If the running mode is not set to MediaPipeTask.RUNNING_MODE_LIVE_STREAM, update the running mode and initialize the task.
	if not running_mode == MediaPipeTask.RUNNING_MODE_LIVE_STREAM:
		running_mode = MediaPipeTask.RUNNING_MODE_LIVE_STREAM
		init_task()
	# Convert the image to CPU format if the delegate is set to MediaPipeTaskBaseOptions.DELEGATE_CPU and the image is in GPU format.
	if delegate == MediaPipeTaskBaseOptions.DELEGATE_CPU and image.is_gpu_image():
		image.convert_to_cpu()
	process_camera_frame(image, Time.get_ticks_msec())

# Initialize the task.
func init_task() -> void:
	# TODO: Implement task initialization logic.
	pass

# Process an image frame.
func process_image_frame(image: Image) -> void:
	# TODO: Implement image frame processing logic.
	pass

# Process a video frame.
func process_video_frame(image: Image, timestamp_ms: int) -> void:
	# TODO: Implement video frame processing logic.
	pass

# Process a camera frame.
func process_camera_frame(image: MediaPipeImage, timestamp_ms: int) -> void:
	# TODO: Implement camera frame processing logic.
	pass

# Update the image displayed in the image view.
func update_image(image: Image) -> void:
	if Vector2i(image_view.texture.get_size()) == image.get_size():
		image_view.texture.call_deferred("update", image)
	else:
		image_view.texture.call_deferred("set_image", image)

# Start the camera.
func start_camera() -> void:
	# Reset the task, set the camera mirroring to false, and start the camera with the specified camera ID and resolution.
	reset()
	camera_helper.set_mirrored(false)
	# this may need to change, there is also the need for chaning cameras. 
	camera_helper.start(0, Vector2(640, 480))


# Reset the task.
func reset() -> void:
	# Stop the video player and close the camera.
	video_player.stop()
	camera_helper.close()
