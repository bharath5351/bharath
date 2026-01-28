from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route("/health")
def health():
    return jsonify({"status": "OK"})

@app.route("/")
def root():
    return "Hello  Devops This is a assignment test"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
