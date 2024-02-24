    FROM python:3.9-slim-buster

    LABEL Name="Python Flask Demo App" Version=1.4.2
    LABEL org.opencontainers.image.source = "https://github.com/benc-uk/python-demoapp"

    ARG srcDir=src
    WORKDIR /app
    COPY $srcDir/requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt

    COPY $srcDir/run.py .
    COPY $srcDir/app ./app

    EXPOSE 5000

    # Set up and activate a virtual environment
    RUN python3 -m venv venv
    SHELL ["/bin/bash", "-c"]
    RUN source venv/bin/activate

    # Run your Flask app using python3 run.py
    CMD ["python3", "run.py"]
