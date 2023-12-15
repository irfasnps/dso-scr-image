def source_zip_filename = 'unknown'

pipeline {
	agent {
    	docker {
        	image 'python:3.11'
        	args ' -v /home/jenkins/scr_sast_projects_files/:/source_files '
        }
    }
    environment {
        POLARIS_SERVER_URL = 'https://sig-cons-ms-sca.polaris.synopsys.com'
        POLARIS_ACCESS_TOKEN = credentials('jenkins-polaris-token-scr-vn')
    }
    stages {
        stage('Parameters') {
            steps {
                script {
                    properties([
                        parameters([
                            string(description: 'Provide the name of the project', name: 'project_name', trim: true), 
                            string(description: 'Provide the branch name of the project', name: 'project_branch_name', trim: true),
                            string(description: 'Provide the name of the project\'s source code zip file', name: 'source_zip', trim: true),
                            string(description: 'Enter the language that needs to be scanned for.', name: 'language_in_scope')
                        ])
                    ])
                }
            }
        }
    	stage('VM check') {
        	steps {
            	sh ' cat /etc/*release '
                sh ' python -V '
                sh ' ls -l /source_files '
            }
        }
        stage('Unzip the source code') {
            steps {
                sh ''' 
                    if [ -f "/source_files/${source_zip}" ]; then echo 'File_exists'; fi
                    
                    pwd 
                    echo "${project_name}"
                    echo "${project_branch_name}"
                    echo "${source_zip}"
                    echo "${languages_in_scope}"
                
                    mkdir ${WORKSPACE}/${BUILD_NUMBER} 
                    cp /source_files/$source_zip ${WORKSPACE}/${BUILD_NUMBER}/
                    cd ${WORKSPACE}/${BUILD_NUMBER} && ls -l
                    
                    source_zip_filename=`basename ${source_zip} .zip`
                    echo "source_zip_filename -> ${source_zip_filename}"
                    
                    pwd
                    
                    unzip -l "${WORKSPACE}/${BUILD_NUMBER}/${source_zip}"
                    unzip "${WORKSPACE}/${BUILD_NUMBER}/${source_zip}" -d "${WORKSPACE}/${BUILD_NUMBER}"
                
                    pwd && ls -l ${WORKSPACE}/${BUILD_NUMBER}
                    ls -l "${source_zip_filename}"

                '''
                stash includes: "${WORKSPACE}/${BUILD_NUMBER}/${source_zip_filename}/**/*", allowEmpty: true, name: 'source_code'
            }
        }
        stage('Cloc run') {
            steps {
                    sh ' cloc --version '
                    fileExists 'source_code'
                    unstash 'source_code'
                    sh ' pwd && ls -l '
                    sh ' cloc --md '
            }
        }
        stage('Coverity on Polaris') {
            steps {
                    sh " cd ${WORKSPACE}/${BUILD_NUMBER} "
                    fileExists 'source_code2'
                    fileExists 'source_code'
                    unstash 'source_code'
                    sh '''
                        pwd && ls -l
                        cd "${source_zip_filename}"
                        pwd && ls -l

                        datetime = `date +"%Y-%m-%dT%H:%M:%SZ"`
                        echo "datetime -> $datetime"

                        mv /scr/polaris_tmpl.yml polaris.yml

                        sed -i "s/$project_name/${project_name}_${language_in_scope}/g" polaris.yml 
                        sed -i "s/$project_name/${project_branch_name}/g" polaris.yml 
                        sed -i "s/$lang_in_scope/${language_in_scope}/g" polaris.yml 
                        sed -i "s/$scan_time/$datetime/g" polaris.yml
                        sed -i "s/$polaris_url/${env.POLARIS_SERVER_URL}/g" polaris.yml

                        cat polaris.yml

                        polaris --version
                        polaris capture
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
