from flask import Flask, render_template, redirect
from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, SubmitField
import redis
import dns.resolver
import sys

# System Config
app = Flask(__name__)
app.config.update(dict(SECRET_KEY="scretkey"))

my_resolver = dns.resolver.Resolver()
my_resolver.timeout = 2
my_resolver.lifetime = 2

my_resolver.nameservers = [sys.argv[1]]

ip = ""
try:
	ip = my_resolver.query('redis.service.consul', 'A')[0]
except:
	pass
	
if ip != "":
	redis_host = ip.to_text()
else :
	redis_host = "redis"


r = redis.Redis(redis_host)

# Auto-gen first key
if ( r.exists('id')==False ):
	r.set('id','0')

# Create Object
class CreateTask(FlaskForm):
	title = StringField('Task Title')
	shortdesc = StringField('Short Description')
	priority = IntegerField('Priority')
	create = SubmitField('Create')

# Delete Object
class DeleteTask(FlaskForm):
	key = StringField('Task Key') # Delte by task key
	title = StringField('Task Title')
	delete = SubmitField('Delete')

# Create Function
def createTask(form):
	title = form.title.data
	priority = form.priority.data
	shortdesc = form.shortdesc.data
	task = {'title':title, 'shortdesc':shortdesc, 'priority':priority}

	# Auto-gen  key
	r.hmset('TA'+str(r.get('id')), task )
	r.incr("id")
	return redirect('/tasks')

# Delte Function
def deleteTask(form):
	key = form.key.data
	title = form.title.data

	if ( key ):
		r.delete(key)
	else:
		for i in r.keys(pattern='TA*'):
			if r.hget(i,'title')==title: 
				r.delete(i)
	return redirect('/tasks')

# Web App
@app.route('/', methods=['GET','POST'])
def main():
	# Create Form
	cform = CreateTask(prefix='cform')
	dform = DeleteTask(prefix='dform')

	# Reponse
	if cform.validate_on_submit() and cform.create.data:
		return createTask(cform)
	if dform.validate_on_submit() and dform.delete.data:
		return deleteTask(dform)

	return render_template('home.html', cform=cform, dform=dform)

@app.route('/tasks')
def tasks():
	
	# Get data
	keys = r.keys(pattern='TA*')
	val = {}
	for i in keys:
		val[i] = r.hgetall(i)
	return render_template('tasks.html', keys=keys, val=val)

if __name__ == '__main__':
	app.run( host='0.0.0.0', port=80, debug=True) # Execute
