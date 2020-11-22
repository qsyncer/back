# pylint: disable=all
import os

from gunicorn import glogging  # type: ignore

"""
Gunicorn settings documentation: http://docs.gunicorn.org/en/stable/settings.html
"""
bind = f"0.0.0.0:{os.getenv('GUNICORN_PORT', 8000)}"
pythonpath = "."
workers = int(os.getenv("GUNICORN_WORKERS_COUNT", 2))
threads = int(os.getenv("GUNICORN_THREADS_PER_WORKER_COUNT", 4))
worker_class = os.getenv("GUNICORN_WORKER_CLASS", "gthread")
worker_tmp_dir = "/dev/shm"
accesslog = "-"

glogging.Logger.error_fmt = (
    '{"level": "%(levelname)s", "message": "%(message)s", "logger.name": "%(name)s"}'
)
