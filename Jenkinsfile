#!/usr/bin/env groovy

library 'devops-tools-jenkins'

def dockerRegistry = libraryResource('dockerregistry').trim()
def dockerImage = "${dockerRegistry}/bbc-news/elixir-centos7:1.13.1"

library 'BBCNews'

def cosmosServices = [
    'mozart-fetcher-eu-west-1',
    'mozart-fetcher-weather-eu-west-1',
    'mozart-fetcher-sport-eu-west-1'
]

String buildVariables() {
  def envFile = readFile 'build.env'
  def envVars = ''
  envFile.split('\n').each { env ->
    envVars = "$envVars -e $env"
  }
  envVars
}

node {
  cleanWs()
  checkout scm

  properties([
      buildDiscarder(logRotator(daysToKeepStr: '7', artifactDaysToKeepStr: '7')),
      disableConcurrentBuilds(),
      parameters([
          choice(choices: ['test', 'live'], description: 'the branch of bbc/mozart-fetcher to pull in and build', name: 'ENVIRONMENT'),
          booleanParam(defaultValue: false, description: 'Force release from non-master branch', name: 'FORCE_RELEASE')
      ])
  ])

  stage('Checkout mozart-fetcher-build') {
    sh 'mkdir -p mozart-fetcher-build'
    dir('mozart-fetcher-build') {
      git url: 'https://github.com/bbc/mozart-fetcher-build', credentialsId: 'de1d9453-493a-4f18-a2ab-507822b96188', branch: 'master'
    }
  }

  stage('Run tests') {
    docker.image(dockerImage).inside("-u root -e MIX_ENV=test") {
      sh 'mix deps.get'
      sh 'mix test'
    }
  }

  if(params.ENVIRONMENT == 'test') {
    stage('Build executable') {
      String vars = buildVariables()
      docker.image(dockerImage).inside("-u root -e MIX_ENV=prod ${vars}") {
        sh 'mix deps.get'
        sh 'mix distillery.release'
      }
      sh 'cp _build/prod/rel/mozart_fetcher/releases/*/mozart_fetcher.tar.gz SOURCES/'
    }

    BBCNews.archiveDirectoryAsPackageSource("bake-scripts", "bake-scripts.tar.gz")
    BBCNews.buildRPMWithMock(cosmosServices.first(), 'mozart-fetcher.spec', params.FORCE_RELEASE)
  }

  cosmosServices.each { service ->
    if(params.ENVIRONMENT == 'test') {
      BBCNews.setRepositories(service, 'mozart-fetcher-build/repositories.json')
      BBCNews.cosmosRelease(service, 'RPMS/*.x86_64.rpm', params.FORCE_RELEASE)
    }
    BBCNews.uploadCosmosConfig(service, params.ENVIRONMENT, "mozart-fetcher-build/cosmos_config/${params.ENVIRONMENT}-${service}.json", params.FORCE_RELEASE)
  }
  cleanWs()
}
