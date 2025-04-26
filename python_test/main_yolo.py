from ultralytics import YOLO
import cv2

# Load the model once
model = YOLO("yolo11n_openvino_model/")

def run_inference(frame):
    # Run inference
    results = model(frame)
    # Draw the results on the frame
    annotated_frame = results[0].plot()
    return annotated_frame

# Define GStreamer pipeline correctly
pipeline = "videotestsrc ! videoconvert ! video/x-raw,format=BGR ! appsink"

# Open GStreamer pipeline
cap = cv2.VideoCapture(pipeline, cv2.CAP_GSTREAMER)

if not cap.isOpened():
    print("Error: Could not open GStreamer pipeline.")
    print("Backend available:", cv2.getBuildInformation())
    raise Exception("Error: Could not open GStreamer pipeline.")


while True:
    ret, frame = cap.read()
    if not ret:
        print("Error: Could not read frame.")
        break

    # Run inference on frame (optional, comment if just testing)
    frame = run_inference(frame)

    # Show frame
    cv2.imshow("Video Analysis", frame)

    # Press 'q' to exit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
