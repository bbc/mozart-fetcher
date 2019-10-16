#!/usr/bin/env groovy

library 'BBCNews'

def cosmosServices = [
    'mozart-fetcher-eu-west-1',
    'mozart-fetcher-eu-west-2',
    'mozart-fetcher-weather-eu-west-1',
    'mozart-fetcher-weather-eu-west-2',
    'mozart-fetcher-sport-eu-west-1',
    'mozart-fetcher-sport-eu-west-2'
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
      disableConcurrentBuilds(),
      parameters([
          choice(choices: ['test', 'live'], description: 'the branch of bbc/mozart-fetcher to pull in and build', name: 'ENVIRONMENT'),
          booleanParam(defaultValue: false, description: 'Force release from non-master branch', name: 'FORCE_RELEASE')
      ])
  ])

  stage('Checkout mozart-fetcher-build') {
    sh 'mkdir -p mozart-fetcher-build'
    dir('mozart-fetcher-build') {
      git url: 'https://github.com/bbc/mozart-fetcher-build', credentialsId: 'github', branch: 'master'
    }
  }
  if(params.ENVIRONMENT == 'test') {
    stage('Build executable') {
      String vars = buildVariables()
      docker.image('qixxit/elixir-centos').inside("-u root -e MIX_ENV=prod ${vars}") {
        sh 'mix deps.get'
        sh 'mix release'
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
}
