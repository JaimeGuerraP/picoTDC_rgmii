#!/usr/bin/env python3

# Dependencies:
#    - python-gitlab
#    - pygit2

import os
import shutil
import zipfile
import pygit2
import gitlab

#############
# Functions #
#############
def findLastJob(pipelines, stage):
    for pipeline in pipelines:
        jobs = pipeline.jobs.list()
        for job in jobs:
            if job.stage == stage and job.status == 'success':
                return job

    return None

###############
# Check Func. #
###############
def checkPreviousPipeline():
    ''' Configuration '''
    try:
        privateToken = os.environ['CI_PRIVATE_TOKEN']
        projectId = 37640
        repo = pygit2.Repository('..')
        head = repo.lookup_reference('HEAD').resolve()
        branchName = os.path.basename(head.name)
        if branchName == 'HEAD':
            branchName = os.environ['CI_COMMIT_REF_NAME']
    except:
        print('<W> Configuration failed: could be because the script is being run locally - firmware have to be compiled')
        return -1

    fwCompileStage = 'fwTimingCheck'

    print('<I> Refs: {}'.format(branchName))

    ''' Get project '''
    try:
        gl = gitlab.Gitlab('http://gitlab.cern.ch/', private_token=privateToken)
        project = gl.projects.get(projectId)
    except:
        return -1 # Getting the project failed -> trigger a compilation

    ''' Get all pipeline for this ref '''
    pipelines = project.pipelines.list(ref=branchName)
    if len(pipelines) < 1:
        print("<W> No corresponding pipelines found - firmware have to be compiled")
        return -1

    lastFwCompilationJob = findLastJob(pipelines, fwCompileStage)

    ''' Have we already compiled the firmware? '''
    if  lastFwCompilationJob is None:
        print("<W> No Fw compilation found")
        return -1

    ''' Did the previous job succeeded? '''
    if lastFwCompilationJob.status != 'success':
        print("<E> Last Fw compilation failed but no Fw files were modified - it will fail again !")
        return -2

    print("<I> Last compilation date: {}".format(lastFwCompilationJob.created_at))
    print("<I> Last compilation Commit: {}".format(lastFwCompilationJob.commit['id']))

    try:
        current = repo[repo.head.target.hex]
        last = repo[lastFwCompilationJob.commit['id']]
    except KeyError:
        print("<W> Commit not found in repo, rerunning implementation.")
        return -1

    diff_var = repo.diff(current, last)
    for diff_item in diff_var:
        newfile_name= diff_item.delta.new_file.path
        if ('firmware/' in newfile_name) or (os.path.basename(newfile_name) == 'lpgbt_tester.xml'):
            if os.path.basename(newfile_name) != 'ipbus_decode_lpgbt_tester.vhd' and \
               os.path.basename(newfile_name) != 'versionregs.vhd' and \
               os.path.basename(newfile_name) != 'CIChecker.py' and \
               os.path.basename(newfile_name) != 'makeit.py' :
                print("<W> Fw file(s) modified - new compilation is needed")
                return -1

    ''' Get artifact '''
    with open('artifacts.zip', "wb") as f:
        project.jobs.get(lastFwCompilationJob.id, lazy=True).artifacts(streamed=True, action=f.write)

    bitFilePaths = []
    with zipfile.ZipFile('artifacts.zip', 'r') as z:
        names = z.namelist()
        for name in names:
            if '.bit' in name:
                bitFilePaths.append(name)

        if not bitFilePaths:
            print('<W> Bitfile not found - compilation is needed')
            return -1

        for bitFilePath in bitFilePaths:
            basename = os.path.basename(bitFilePath)
            binDir = 'bin'

            if not os.path.exists(binDir):
                os.makedirs(binDir)

            print("<I> BitFile: {}".format(bitFilePath))
            with z.open(bitFilePath) as zf, open(os.path.join(binDir, basename), 'wb') as f:
                shutil.copyfileobj(zf, f)
