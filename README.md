# A quest in the clouds - Steven Staley Submission

## Dependencies
* Docker
* Nodejs 10
* jq

## Setup 

Note: This won't build/deploy the image. At this point you'll see 503s. Build/Deploy is next step.

```
./doit.sh create-infra --profile <profile> --region <region>
```

## Deployment 

```
./doit.sh login-docker --profile <profile> --region <region>
./doit.sh build --profile <profile> --region <region> --secret-word "SecretWord"
./doit.sh deploy --profile <profile> --region <region>
```

## Tear Down 

```
./doit.sh destroy --profile <profile> --region <region>
```


## Issues and Fixes

  1) Dockerfile ENV vars don't change the build, and since this is using a deploy to 'latest', it means the image actually has to be removed & re-uploaded to deploy new env vars. It would be best to be able to change env vars dynamically. 

  How can this be fixed?

  A better approach would be to use ECS's native environment variable injection via the task definition. This can be done in the task definition's "container definition" with Terraform or by using the [ecs-cli compose create command](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-create.html) along with a docker-compose file & ecs-parameter file. Using the latter method, the task definition's ARN would be passed to the ECS Terraform & ignored. This is nice because it allows you to separate management of the task definition from Terraform which leaves the door open to using deployment providers like CodeDeploy without getting out of sync with Terraform state (while still maintaining your task definition in a configuration file). 

  2) The "secret word" isn't so secret. 

  How can this be fixed?

  If this secret word were actually a secret, using `--build-arg` isn't the best option because it leaves traces. An alternatve would be to set up a secure SSM parameter, which can also be injected into the container using ECS's native support for SSM environment variables.

  3) Not ent to end encrypted (TLS terminates at ALB)

  How can this be fixed?

  Add a proxy sidecar to the ECS deployment with certificate.

  4) The source code doesn't recognize that it's in a docker container on Fargate. 

  Not sure how this can be fixed, but I thought I'd point it out. 

   