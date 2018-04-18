[
	{
		"name": "myapp",
		"essential": true,
		"memory": 256,
		"cpu": 256,
		"image": "${REPOSITORY_URL}:myapp",
		"links": [],
		"portMappings": [
			{
				"containerPort": 80,
				"hostPort": 80,
				"protocol": "tcp"
			}
		],
		"entryPoint": [],
        "command": [],
        "environment": [],
        "mountPoints": [],
        "volumesFrom": []
	}
]
