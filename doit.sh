#!/bin/bash

print_red () {
  printf "\033[31m$1\n\033[0m"
}

print_green() {
  printf "\033[32m$1\n\033[0m"
}

usage () {
  printf "Usage:\\n"
  print_green "./doit.sh build|deploy|create-infra  ...flags\\n
    build
      --profile|-p       optional AWS profile flag will run commands with provided profile
      --region|-r        required AWS region
      --secret-word      required secret word to be used in docker container
      --help|-h          output this message
    deploy
      --profile|-p       optional AWS profile flag will run commands with provided profile
      --region|-r        required AWS region
      --environment|e    optional environment. Defaults to \"tst\".
      --help|-h          output this message
    create-infra
      --profile|-p       optional AWS profile flag will run commands with provided profile
      --region|-r        required AWS region
    destroy
      --profile|-p       optional AWS profile flag will run commands with provided profile
      --region|-r        required AWS region
    "
}

if [ "$1" != "build" ] && [ "$1" != "deploy" ] && [ "$1" != "create-infra" ] && [ "$1" != "destroy" ];
then
  echo "First argument must be one of \"build\",\"deploy\",\"create-infra\",\"destroy\"" && usage && exit 1;
fi

# CLI input
while test $# -gt 0; do
  case "$1" in
    build)
      shift
      BUILD="true"
      ;;
    deploy)
      shift
      DEPLOY="true"
      ;;
    create-infra)
      shift
      CREATE="true"
      ;;
    destroy)
      shift
      DESTROY="true"
      ;;
    --profile|-p)
      shift
      PROFILE=$1
      shift
      ;;
    --region|-r)
      shift
      REGION=$1
      shift
      ;;
    --secret-word|-s)
      shift
      SECRET_WORD=$1
      shift
      ;;
    --environment|-ec)
      shift
      ENVIRONMENT=$1
      shift
      ;;
    --help|-h)
      shift
      HELP=true
      shift
      ;;
    *)
      echo "$1 is not a recognized flag!"
      usage
      exit 1;
      ;;
  esac
done

if [ -n "$HELP" ]; then usage && exit 0; fi

if [ -z "$REGION" ]; then print_red "--region is a required flag\n" && usage && exit 1; fi

if [ -n "$BUILD" ] && [ -z "$SECRET_WORD" ]; then print_red "--secret_word is a required flag\n" && usage && exit 1; fi

if [ -z "$PROFILE" ]; then PROFILE="default"; fi

if [ -z "$ENVIRONMENT" ]; then ENVIRONMENT="tst"; fi

if [ "$REGION" == "us-west-1" ]; then SHORT_REGION="usw1"; fi
if [ "$REGION" == "us-west-2" ]; then SHORT_REGION="usw2"; fi
if [ "$REGION" == "eu-central-1" ]; then SHORT_REGION="euc1"; fi
if [ "$REGION" == "eu-west-1" ]; then SHORT_REGION="euw1"; fi
if [ "$REGION" == "eu-west-2" ]; then SHORT_REGION="euw2"; fi
if [ "$REGION" == "eu-west-3" ]; then SHORT_REGION="euw3"; fi
if [ "$REGION" == "eu-north-1" ]; then SHORT_REGION="eun1"; fi
if [ "$REGION" == "eu-south-1" ]; then SHORT_REGION="eus1"; fi
if [ "$REGION" == "us-east-1" ]; then SHORT_REGION="use1"; fi
if [ "$REGION" == "us-east-2" ]; then SHORT_REGION="use2"; fi
if [ "$REGION" == "af-south-1" ]; then SHORT_REGION="afs1"; fi
if [ "$REGION" == "ap-east-1" ]; then SHORT_REGION="ape1"; fi
if [ "$REGION" == "ap-south-1" ]; then SHORT_REGION="aps1"; fi
if [ "$REGION" == "ap-northeast-1" ]; then SHORT_REGION="apne1"; fi
if [ "$REGION" == "ap-northeast-2" ]; then SHORT_REGION="apne2"; fi
if [ "$REGION" == "ap-northeast-3" ]; then SHORT_REGION="apne3"; fi
if [ "$REGION" == "ap-southeast-1" ]; then SHORT_REGION="apse1"; fi
if [ "$REGION" == "ap-southeast-2" ]; then SHORT_REGION="apse2"; fi
if [ "$REGION" == "ca-central-1" ]; then SHORT_REGION="cac1"; fi
if [ "$REGION" == "cn-north-1" ]; then SHORT_REGION="cnn1"; fi
if [ "$REGION" == "cn-northwest-1" ]; then SHORT_REGION="cnnw1"; fi
if [ "$REGION" == "me-south-1" ]; then SHORT_REGION="mes1"; fi
if [ "$REGION" == "sa-east-1" ]; then SHORT_REGION="sae1"; fi


if [ -z "$DESTROY" ] && [ -n "$CREATE" ];
then
  cd infra/network
  terraform init && terraform apply -var "aws_profile=$PROFILE" -var "aws_region=$REGION" -auto-approve
  cd ../ecr
  terraform init && terraform apply -var "aws_profile=$PROFILE" -var "aws_region=$REGION" -auto-approve
  cd ../ecs
  terraform init && terraform apply -var "aws_profile=$PROFILE" -var "aws_region=$REGION" -auto-approve
  cd ../../
fi

if [ -n "$DESTROY" ];
then
  cd infra/ecs
  terraform init && terraform destroy -var "aws_profile=$PROFILE" -var "aws_region=$REGION" -auto-approve
  cd ../ecr
  terraform init && terraform destroy -var "aws_profile=$PROFILE" -var "aws_region=$REGION" -auto-approve
  cd ../network
  terraform init && terraform destroy -var "aws_profile=$PROFILE" -var "aws_region=$REGION" -auto-approve
  cd ../../
fi

if [ -z "$DESTROY" ] && [ -n "$BUILD" ];
then
  ACCOUNT_ID=$(aws --profile "$PROFILE" sts get-caller-identity | jq ".Account" | sed 's/\"//g')
  if [ -n "$SECRET_WORD" ];
  then 
    echo "building..."
    docker build  --build-arg SECRET_WORD="$SECRET_WORD" . -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/quest:latest
  else 
    echo "building..."
    docker build --build-arg SECRET_WORD="$SECRET_WORD" . -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/quest:latest 
  fi
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/quest:latest
fi

if [ -z "$DESTROY" ] && [ -n "$DEPLOY" ];
then
  aws ecs --profile "$PROFILE" --region "$REGION" update-service --service rearc-quest-$SHORT_REGION-$ENVIRONMENT --cluster "rearc-cluster"
fi