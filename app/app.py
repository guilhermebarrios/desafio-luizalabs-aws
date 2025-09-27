from flask import Flask
# Importa a biblioteca de métricas
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
# Aplica o "wrapper" de métricas no seu app.
# Isso cria automaticamente o endpoint /metrics para você!
metrics = PrometheusMetrics(app)

@app.route("/")
def hello():
    return "Hello, Magalu iPET! - Guilherme Barrios"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)