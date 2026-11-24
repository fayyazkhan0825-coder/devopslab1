# DevOps Lab 1 - Foundations and Continuous Integration

Student: Fayyaz Ahmad
Course: DevOps Laboratory, Experiment 1

A Flask sample application with a Jenkins declarative pipeline that
lints, tests, packages, deploys and smoke-tests it on every push to
`main`.

## Pipeline stages

1. Checkout - clone the repository and print the recent history
2. Setup Environment - create a virtual environment, install dependencies
3. Lint - flake8
4. Test - pytest, results published as JUnit XML
5. Build Artifact - versioned tar.gz plus sha256, archived in Jenkins
6. Deploy - unpack the artifact and restart the application (main only)
7. Smoke Test - call /health and / on the running service (main only)

## Run it locally

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -v
python -m app.main
curl http://localhost:8000/health
```

## Evidence

Commands in `docs/commands.md`, notes in `docs/observations.md`,
screenshots in `docs/screenshots/`.
