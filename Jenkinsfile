//def source_zip_filename = 'unknown'

pipeline {
	agent {
	    dockerfile {
        	args ' -v /home/jenkins/scr_sast_projects_files/:/source_files:rw '
    	}
    }
    environment {
        POLARIS_SERVER_URL = 'https://sig-cons-ms-sca.polaris.synopsys.com'
        POLARIS_ACCESS_TOKEN = credentials('jenkins-polaris-token-scr-vn')
        SOURCE_ZIP_FILE = 'unknown'
	POLARIS_HOME = '$HOME/.synopsys/polaris'
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
                            string(description: 'Enter the language that needs to be scanned for.', name: 'languages_in_scope')
                        ])
                    ])
                }
            }
        }
    	stage('VM check') {
        	steps {
		sh ' echo ${project_name} '
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

                    unzip -l "${source_zip}"
                    unzip "${source_zip}"
                
                    pwd && ls -l ${WORKSPACE}/${BUILD_NUMBER}
                
                    ls -l ${WORKSPACE}/${BUILD_NUMBER}
                    ls -l "${source_zip_filename}"
		    cd "${source_zip_filename}"

                '''
                stash includes: "${WORKSPACE}/${BUILD_NUMBER}/${SOURCE_ZIP_FILE}/**/*", allowEmpty: true, name: 'source_code'
            }
        }
        stage('Cloc run') {
            steps {
                    fileExists 'source_code'
                    unstash 'source_code'
                    sh '''
                        cd ${WORKSPACE}/${BUILD_NUMBER}
                        pwd && ls -l

                        SOURCE_ZIP_FILE=`basename ${source_zip} .zip`
                        echo "source_zip_filename -> ${SOURCE_ZIP_FILE}"

                        cd "${SOURCE_ZIP_FILE}"
                        pwd && ls -l 

                        cloc --version
                        cloc --md . 
                    '''
            }
        }
        stage('Coverity on Polaris') {
            steps {
                    fileExists 'source_code2'
                    fileExists 'source_code'
                    unstash 'source_code'
                    sh '''
		    	echo ${POLARIS_ACCESS_TOKEN}
                        cd ${WORKSPACE}/${BUILD_NUMBER}
                        pwd && ls -l
                        
                        SOURCE_ZIP_FILE=`basename ${source_zip} .zip`
                        echo "source_zip_filename -> ${SOURCE_ZIP_FILE}"
                        
                        cd "${SOURCE_ZIP_FILE}"
                        pwd && ls -l

                        datetime=`date +"%Y-%m-%dT%H:%M:%SZ"`
                        echo "datetime -> $datetime"

                        cp /scr/polaris_tmpl.yml polaris.yml
			cat polaris.yml
                        sed -i "s/_project_name/${project_name}/g" polaris.yml 
                        sed -i "s/_project_branch_name/${project_branch_name}/g" polaris.yml 
                        sed -i "s/_lang_in_scope/${languages_in_scope}/g" polaris.yml 
                        sed -i "s/_scan_time/$datetime/g" polaris.yml
			cat polaris.yml
                        sed -i "s,https://_polaris_url,${POLARIS_SERVER_URL},g" polaris.yml

                        cat polaris.yml
			mkdir polaris
			POLARIS_HOME=${WORKSPACE}/${BUILD_NUMBER}/${SOURCE_ZIP_FILE}/polaris
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
