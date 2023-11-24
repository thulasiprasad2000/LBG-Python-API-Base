FROM python:latest

WORKDIR /app

COPY . .

ENV PORT=8080

RUN pip install -r "requirements.txt"

EXPOSE ${PORT}

ENTRYPOINT ["python", "lbg.py"]
