FROM python:2.7-onbuild
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "-u", "api.py", "${MYHOST}"]


