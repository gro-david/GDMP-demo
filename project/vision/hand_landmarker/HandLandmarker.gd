# FILEPATH: /home/macisajt/Downloads/GDMP-demo/project/vision/hand_landmarker/HandLandmarker.gd

# This script extends the VisionTask class and implements hand landmark detection using the MediaPipe library.
# It provides functions to initialize the task, process image frames, process video frames, and process camera frames.
# The result of the hand landmark detection is displayed by drawing landmarks on the input image and showing the handedness information.

extends VisionTask

# The MediaPipeHandLandmarker instance used for hand landmark detection.
var task: MediaPipeHandLandmarker

# The file path of the MediaPipe hand landmark detection task.
var task_file := "res://vision/hand_landmarker/hand_landmarker.task"

# The label used to display the handedness information.
@onready var lbl_handedness: Label = $VBoxContainer/Image/Handedness

# Callback function called when a result is received from the MediaPipeHandLandmarker.
# It takes the result, the input image, and the timestamp as parameters.
func _result_callback(result: MediaPipeHandLandmarkerResult, image: MediaPipeImage, _timestamp_ms: int) -> void:
	var img := image.get_image()
	show_result(img, result)

# Initializes the MediaPipeHandLandmarker task.
# It creates the base options, reads the model asset buffer from the task file, and initializes the task.
func init_task() -> void:
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = delegate
	var file := FileAccess.open(task_file, FileAccess.READ)
	base_options.model_asset_buffer = file.get_buffer(file.get_length())
	task = MediaPipeHandLandmarker.new()
	task.initialize(base_options, running_mode, 2)
	task.result_callback.connect(self._result_callback)

# Processes an image frame by detecting hand landmarks using the MediaPipeHandLandmarker task.
# It takes the input image as a parameter.
func process_image_frame(image: Image) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect(input_image)
	show_result(image, result)

# Processes a video frame by detecting hand landmarks using the MediaPipeHandLandmarker task.
# It takes the input image and the timestamp as parameters.
func process_video_frame(image: Image, timestamp_ms: int) -> void:
	var input_image := MediaPipeImage.new()
	input_image.set_image(image)
	var result := task.detect_video(input_image, timestamp_ms)
	show_result(image, result)

# Processes a camera frame by detecting hand landmarks using the MediaPipeHandLandmarker task asynchronously.
# It takes the input image and the timestamp as parameters.
func process_camera_frame(image: MediaPipeImage, timestamp_ms: int) -> void:
	task.detect_async(image, timestamp_ms)

# Displays the result of the hand landmark detection by drawing landmarks on the input image and showing the handedness information.
# It takes the input image and the result as parameters.
func show_result(image: Image, result: MediaPipeHandLandmarkerResult) -> void:
	for landmarks in result.hand_landmarks:
		draw_landmarks(image, landmarks)

	var handedness_text := ""
	for categories in result.handedness:
		for category in categories.categories:
			handedness_text += "%s\n" % [category.display_name]
	lbl_handedness.call_deferred("set_text", handedness_text)
	update_image(image)

# Draws landmarks on the input image.
# It takes the input image and the landmarks as parameters.
func draw_landmarks(image: Image, landmarks: MediaPipeNormalizedLandmarks) -> void:
	var color := Color.GREEN
	var rect := Image.create(4, 4, false, image.get_format())
	rect.fill(color)
	var image_size := Vector2(image.get_size())
	
	var index := -1
	for landmark in landmarks.landmarks:
		index += 1
		if index != 4 and index != 8 and index != 12 and index != 16 and index != 20:
			continue
		var pos := Vector2(landmark.x, landmark.y)
		image.blit_rect(rect, rect.get_used_rect(), Vector2i(image_size * pos) - rect.get_size() / 2)
