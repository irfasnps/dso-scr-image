pipeline {
	agent {
        dockerfile true
    }
    environment {
        POLARIS_SERVER_URL = 'https://sig-cons-ms-sca.polaris.synopsys.com'
        POLARIS_ACCESS_TOKEN = credentials('jenkins-polaris-token-scr-vn')
    }
    stages {
	stage('Git Check'){
		steps {
			sh ' git --version '
		}
	}
        stage('Parameters') {
            steps { 
                //cleanWs()
                script {
                    properties([
                        parameters([
                            string(description: 'Provide the name of the project', name: 'project_name', trim: true), 
                            string(description: 'Provide the branch name of the project', name: 'project_branch_name', trim: true), 
                            base64File(description: 'Upload the source code in a zip format', name: 'source_zip'),
                            text(description: 'Enter the languages that need to be scanned. Enter values in separate lines.', name: 'languages_in_scope')
                            ])
                    ])
                }
            }
        }
    	stage('VM check') {
        	steps {
            	sh ' cat /etc/*release '
                sh ' python -V '
            }
        }
        stage('Unzip the source code') {
            steps {
                script {
                    SOURCE_CODE = "$source_zip"
                }
                echo 'SOURCE_CODE -> '
                echo "$SOURCE_CODE"
                sh " ls -l && pwd "
                echo "$source_zip"
                echo "${project_name}"
                echo "${languages_in_scope}"
                
                sh " mkdir ${WORKSPACE}/${BUILD_NUMBER} "
                withFileParameter(name: 'source_zip', allowNoFile: true) {
                    sh 'if [ -f "$source_zip" ]; then echo $source_zip; fi'
                }
                unzip dir: '${WORKSPACE}/${BUILD_NUMBER}', glob: '', quiet: true, zipFile: '${source_zip}' 

                stash includes: '${WORKSPACE}/${BUILD_NUMBER}/$SOURCE_CODE/**/*', allowEmpty: true, name: 'source_code'
            }
        }
        stage('Cloc run') {
            steps {
                    fileExists 'source_code'
                    unstash 'source_code'
                    sh " pwd && ls -l "
                    sh ' cloc --md '
            }
        }
        stage('Coverity on Polaris') {
            steps {
                    sh " cd ${WORKSPACE}/${BUILD_NUMBER} "
                    fileExists 'source_code'
                    unstash 'source_code'
                    sh " pwd && ls -l "
                    sh '''
                        polaris --version

                        polaris --co project="{branch:${project_branch_name}, name:${project_name}}" \
                            --co capture.coverity.buildless.project.languages=[java,javascript] \
                            analyze
                    '''
            }
        }
    }
    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}
