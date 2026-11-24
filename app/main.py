from flask import Flask, jsonify

app = Flask(__name__)

APP_NAME = "devops-lab1-cicd"
VERSION = "1.0.0"
MAINTAINER = "Fayyaz Ahmad"


@app.get("/")
def index():
    return jsonify(
        application=APP_NAME,
        version=VERSION,
        maintainer=MAINTAINER,
        message="Deployed by Jenkins CI/CD pipeline",
    )


@app.get("/health")
def health():
    return jsonify(status="healthy", version=VERSION), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
