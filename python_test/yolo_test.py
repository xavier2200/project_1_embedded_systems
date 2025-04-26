from ultralytics import YOLO
import cv2

# Load the model only ONCE (not inside the loop)
model = YOLO("yolo11n_openvino_model/")  # load outside to avoid reloading every frame

def run_inference(frame):
    # Run inference
    results = model(frame)
    
    # Draw the results on the frame
    annotated_frame = results[0].plot()
    
    return annotated_frame

def simple_camera_view():
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Could not read frame.")
            break

        frame = run_inference(frame)

        cv2.imshow("Camera Stream", frame)

        # Exit if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

# Call the function
simple_camera_view()

