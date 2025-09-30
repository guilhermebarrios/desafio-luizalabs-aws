from flask import Flask
# Importa a biblioteca de métricas
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
# Aplica o "wrapper" de métricas no seu app.
# Isso cria automaticamente o endpoint /metrics
metrics = PrometheusMetrics(app)

@app.route("/")
def hello():
   return """
    <html>
        <head>
            <title>Magalu iPET</title>
        </head>
        <body style="display: flex; justify-content: center; align-items: center; height: 100vh;">
            <h1 style="font-size: 48px;">(HelloWord) - Olá, Magalu iPET! - Guilherme Barrios</h1>
        </body>
    </html>
    """

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)