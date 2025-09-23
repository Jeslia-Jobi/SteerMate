# SteerMate

A mobile application for intelligent navigation and assistance, combining machine learning for on-device predictions with a backend for data management.

## Tech Stack
- **Backend**: Python with FastAPI for API services, TensorFlow for model training, and TFLite for mobile deployment.
- **Mobile**: Flutter for cross-platform app development.
- **ML**: On-device inference using TensorFlow Lite models.

## Project Structure
- `backend/`: Server-side logic, model training, and API endpoints.
- `mobile/`: Flutter app for user interface and on-device ML.
- `Progress.md`: Current development roadmap.

## Getting Started
1. Set up the backend: Navigate to `backend/` and install dependencies via `uv` or `pip`.
2. Run the server: Use `uvicorn main:app --reload`.
3. For mobile: Set up Flutter and integrate TFLite models.

See [Progress.md](Progress.md) for next steps.
