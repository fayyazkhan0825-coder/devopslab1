import pytest

from app.main import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_index_returns_application_name(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json()["application"] == "devops-lab1-cicd"


def test_health_endpoint_is_healthy(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"


def test_unknown_route_returns_404(client):
    assert client.get("/does-not-exist").status_code == 404
