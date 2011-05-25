#! /usr/bin/env bash

##############################################################################
# \file  basisproject.sh
# \brief This shell script is used to create or modify a BASIS project.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################
 
# ============================================================================
# default functions
# ============================================================================

@BASH_FUNCTION_getProgDir@
@BASH_FUNCTION_getProgName@

# ============================================================================
# constants
# ============================================================================

progName=$(getProgName) # name of this script
progDir=$(getProgDir)   # directory of this script

versionMajor='@VERSION_MAJOR@' # major version number
versionMinor='@VERSION_MINOR@' # minor version number
versionPatch='@VERSION_PATCH@' # version patch number

# version string
version="$versionMajor.$versionMinor.$versionPatch"

# name of CMake configuration file used to resolve dependencies
dependsFile='Depends.cmake'

# ============================================================================
# usage / help / version
# ============================================================================

# ****************************************************************************
# \brief Prints version information.

version ()
{
	echo "$progName $version"
}

# ****************************************************************************
# \brief Prints contact information.

contact ()
{
    echo "Contact:"
    echo "  SBIA Group <sbia-software -at- uphs.upenn.edu>"
}

# ****************************************************************************
# \brief Prints options information.

options ()
{
    echo "Required Options:"
    echo "  <project name>             Name of the new project."
    echo "  -d [ --description ] arg   Brief project description. Option not allowed when modifying"
    echo "                             an existent project."
    echo "  -r [ --root ] arg          Specify root directory of new project or directory of"
    echo "                             existing project. If the specified directory already exists"
    echo "                             this program will modify this project. The project name and"
    echo "                             description options must not be given in this case as these"
    echo "                             attributes of a project cannot be modified any more."
    echo "Template Options:"
    echo "  --minimal                  Choose minimal project template. Corresponds to not selecting any"
    echo "                             of the additional template files."
    echo "  --standard                 Choose standard project template. This is the default template used"
    echo "                             if no other project template is chosen. Corresponds to:"
    echo
    echo "                               --example"
    echo "                               --system-tests"
    echo "                               --no-conf-components"
    echo "                               --no-conf-depends"
    echo "                               --no-conf-find"
    echo "                               --no-conf-generate"
    echo "                               --no-conf-package"
    echo "                               --no-conf-script"
    echo "                               --no-conf-settings"
    echo "                               --no-conf-use"
    echo "                               --no-conf-version"
    echo "                               --no-etc"
    echo "                               --no-unit-tests"
    echo
    echo "  --full                     Choose full project template. Corresponds to selecting all files."
    echo
    echo "  --conf-components          Whether to include custom Components.cmake file."
    echo "  --conf-depends             Whether to include custom Depends.cmake file."
    echo "  --conf-find                Whether to include custom <project>Config.cmake file."
    echo "  --conf-find-version        Whether to include custom <project>ConfigVersion.cmake file."
    echo "  --conf-generate            Whether to include custom GenerateConfig.cmake script."
    echo "  --conf-package             Whether to include custom Package.cmake file."
    echo "  --conf-script              Whether to include custom ScriptConfig.cmake file."
    echo "  --conf-settings            Whether to include custom Settings.cmake file."
    echo "  --conf-tests               Whether to include custom CTestCustom.cmake file."
    echo "  --conf-use                 Whether to include custom <project>Use.cmake file."
    echo "  --etc                      Whether to include support of software configuration data."
    echo "  --example                  Whether to include support of example."
    echo "  --tests                    Alias for '--system-tests --unit-tests'."
    echo "  --system-tests             Whether to include support of system tests."
    echo "  --unit-tests               Whether to include support of unit tests."
    echo
    echo "  --no-conf-components       Whether to exclude custom Components.cmake file."
    echo "  --no-conf-depends          Whether to exclude custom Depends.cmake file."
    echo "  --no-conf-find             Whether to exclude custom <project>Config.cmake file."
    echo "  --no-conf-find-version     Whether to exclude custom <project>ConfigVersion.cmake file."
    echo "  --no-conf-generate         Whether to exclude custom GenerateConfig.cmake script."
    echo "  --no-conf-package          Whether to exclude custom Package.cmake file."
    echo "  --no-conf-script           Whether to exclude custom ScriptConfig.cmake file."
    echo "  --no-conf-settings         Whether to exclude custom Settings.cmake file."
    echo "  --no-conf-tests            Whether to exclude custom CTestCustom.cmake file."
    echo "  --no-conf-use              Whether to exclude custom <project>Use.cmake file."
    echo "  --no-etc                   Whether to exclude support of software configuration data."
    echo "  --no-example               Whether to exclude support of example."
    echo "  --no-tests                 Alias for '--no-system-tests --no-unit-tests --no-conf-tests'."
    echo "  --no-system-tests          Whether to exclude support of system tests."
    echo "  --no-unit-tests            Whether to exclude support of unit tests."
    echo
    echo "  -p [ --pkg ] arg           Name of external package required by this project."
    echo "  --optPkg arg               Name of external package optionally used by this project."
    echo
    echo "Options:"
    echo "  --clean                    Remove backup and other temporary files left behind."
    echo "  --clean-all                Remove not only backup and other temporary files, but also"
    echo "                             the hidden '.basis' directories with copies of the template files."
    echo "  --force                    Force deletion of modified template files."
    echo "  --no-update                Do not update existing files. Only add new files."
    echo "                             By default, in case of existing files, the project file is updated"
    echo "                             by merging changes of the possibly newer template and the existing file."
    echo "  --no-backup                Do not backup project files before updating them."
    echo "                             By default, before any existing project file is modified,"
    echo "                             it is copied to a file with extension '~' before."
    echo "                             The creation of these backup files is disabled by this option."
    echo "  -t [ --template ] arg      Root directory of project template."
    echo
    echo "  -v [ --verbose ]           Increases verbosity of output messages. Can be given multiple times."
    echo "  -h [ --help ]              Displays help and exit."
    echo "  -u [ --usage ]             Displays usage information and exits."
    echo "  -V [ --version ]           Displays version information and exits."
}

# ****************************************************************************
# \brief Prints usage information.

usage ()
{
    echo "$progName $versionMajor.$versionMinor"
    echo
    echo "Usage:"
	echo "  $progName [options] <project name>"
    echo
    options
    echo
    contact
}

# ****************************************************************************
# \brief Prints help.

help ()
{
    echo "$progName $versionMajor.$versionMinor"
    echo
    echo "Usage:"
	echo "  $progName [options] <project name>"
	echo
	echo "Description:"
    echo "  This command-line tool can be used to create a new BASIS project from the"
    echo "  template version $versionMajor.$versionMinor or to modify or upgrade an already existing project."
    echo
    echo "  Depending on the grade of customization or optional inclusion of template"
    echo "  components, different subsets of the fully featured project template can be"
    echo "  selected. Additional template files and folders can be added to an existing"
    echo "  project at any time. Further, if the --no-* options are given explicitly,"
    echo "  project files previously copied from the template are deleted. Files are,"
    echo "  however, only deleted if they were not modified by the project developer since"
    echo "  their creation and hence do not contain project related changes. Similarly are"
    echo "  directories deleted by this tool only if empty. The deletion of modified files"
    echo "  can be forced by using the --force option. Non-empty directories are yet kept"
    echo "  and have to be deleted manually."
    echo
    echo "  An additional feature of this tool is, that it can upgrade an existing project"
    echo "  to a newer project template version, given that the existing directory structure"
    echo "  and file names were preserved. User changes to previously added template files"
    echo "  are preserved and merged with the changes of the template using a so-called"
    echo "  three-way diff using diff3 similar to the Subversion tool svn. Therefore, copies"
    echo "  of the template files which a project file was created from are stored in hidden"
    echo "  '.basis' subdirectories under each directory. These directories should be kept and"
    echo "  commited to the version control system if it is intended to manage the project"
    echo "  files using this tool in the future, e.g., to upgrade to a newer template version."
    echo "  Otherwise, the option --clean-all can be used to have this tool delete those"
    echo "  directories from the project."
    echo
    echo "  Besides the name of the new project and a brief description, names of external"
    echo "  packages required or optionally used by this project can be specified. For each"
    echo "  such package, an entry in the project's $dependsFile file is created. If the"
    echo "  package is not supported explicitly by BASIS, generic CMake statements to"
    echo "  find the package are added. Note that these may not work for this unsupported"
    echo "  package. In this case, the $dependsFile file has to be edited manually."
    echo "  Note that if an existing project is modified, the $dependsFile file is added if"
    echo "  not yet existent, ignoring the option --no-config-depends."
    echo
	options
    echo
    echo "Examples:"
	echo "  $progName ProjectName -d \"Novel image analysis method.\""
    echo "    Create a new project named 'ProjectName' under the current working"
    echo "    directory using the default project template."
    echo
	echo "  $progName ProjectName -d \"Novel image analysis method.\" -p VTK"
    echo "    Create new project with dependency on the package 'VTK'."
    echo
    echo "  $progName -r path/to/existing/project --tests --conf-tests"
    echo "    Add full testing support to existing project."
    echo
    echo "  $progName -r path/to/existing/porject -p ITK --optPkg Matlab"
    echo "    Add dependencies on ITK (mandatory) and MATLAB (optional) to existing project."
    echo
    contact
}

# ============================================================================
# helpers
# ============================================================================

# ****************************************************************************
# \brief Make path absolute.
#
# This function returns the absolute path via command substitution, i.e.,
# use it as follows:
#
# \code
# abspath=$(makeAbsolute $relpath)
# \endcode
#
# \param [in]  1      The (relative) path of a file or directory
#                     (does not need to exist yet).
# \param [out] stdout Prints the absolute path of the specified file or
#                     directory to STDOUT.
#
# \return 0 on success and 1 on failure.
makeAbsolute ()
{
    local path="$1"

    if [ -z "$path" ]; then
        echo "makeAbsolute (): Argument missing!" 1>&2
        return 1
    else
        [ "${path/#\//}" != "$path" ] || path="$(pwd)/$path"
    fi

    echo "$path"
    return 0
}

# ****************************************************************************
# \brief Extract project name from existing project.

getProjectName ()
{
    local active=0
    local name=''

    while read -r line; do
        if [[ $line == *basis_project_initialize* ]]; then
            active=1
        fi
        if [ $active -ne 0 ]; then
            name=$(echo $line | grep 'NAME[ ]\+' | sed 's/.*\"\(.*\)\".*/\1/')
            if [ ! -z "$name" ]; then
                break
            fi
            if [[ $line == *\)* ]]; then
                active=0
                break
            fi
        fi
    done < "$root/CMakeLists.txt"
    echo $name
}

# ============================================================================
# options
# ============================================================================

# ----------------------------------------------------------------------------
# default options
# ----------------------------------------------------------------------------

# root directory of project template
template="$progDir/@TEMPLATE_DIR@"

root=""            # root directory of new project (defaults to `pwd`/$name)
name=""            # name of the project to create
description=""     # project description
verbosity=0        # verbosity level of output messages
packageNames=()    # names of packages the new project depends on
packageRequired=() # whether the package at the same index in packageNames
                   # is required or optional
packageNum=0       # length of arrays packageNames and packageRequired
update=1           # whether to update existing files
force=0            # whether to force update or removal of files
backup=1           # whether to backup project files before updating them
clean=0            # whether to remove backup and other temporary files
cleanAll=0         # whether to remove all additional files

minimal=1          # start with minimal project template
confSettings=0     # add/remove project settings file
confDepends=0      # add/remove dependencies configuration file
confComponents=0   # add/remove components configuration file
confPackage=0      # add/remove package configuration file
confFind=0         # add/remove find package configuration file
confFindVersion=0  # add/remove find package configuration version file
confGenerate=0     # add/remove generate find package configuration script
confScript=0       # add/remove script configuration file
confTests=0        # add/remove testing configuration file
confUse=0          # add/remove unit testing
etc=0              # add/remove software configuration data
example=1          # add/remove example
systemTests=0      # add/remove system testing
unitTests=0        # add/remove unit testing
 
# ----------------------------------------------------------------------------
# parse options
# ----------------------------------------------------------------------------

while [ $# -gt 0 ]
do
	case "$1" in
		-u|--usage)
			usage
			exit 0
			;;

		-h|--help)
			help
			exit 0
			;;

		-v|--version)
			version
			exit 0
			;;

        -V|--verbose)
            ((verbosity++))
            ;;

        -t|--template)
            shift
            if [ $# -gt 0 ]; then
                template=$(makeAbsolute $1)
            else
                echo "Option -t requires an argument!" 1>&2
                exit 1
            fi
            ;;
 
        -r|--root)
            if [ ! -z "$root" ]; then
                echo "Option -r may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                root=$(makeAbsolute $1)
            else
                echo "Option -r requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -d|--description)
            if [ ! -z "$description" ]; then
                echo "Option -d may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                description="$1"
            else
                echo "Option -d requires an argument!" 1>&2
                exit 1
            fi
            ;;

        --no-update)
            update=0
            ;;

        --force)
            force=1
            ;;

        -p|--pkg)
            shift
            if [ $# -gt 0 ]; then
                packageNames[$packageNum]="$1"
                packageRequired[$packageNum]=1
                ((packageNum++))
            else
                echo "Option -p requires an argument!" 1>&2
                exit 1
            fi
            ;;

        --optPkg)
            shift
            if [ $# -gt 0 ]; then
                packageNames[$packageNum]="$1"
                packageRequired[$packageNum]=0
                ((packageNum++))
            else
                echo "Option --optPkg requires an argument!" 1>&2
                exit 1
            fi
            ;;

        --minimal)
            minimal=1
            confSettings=-1
            confDepends=-1
            confComponents=-1
            confPackage=-1
            confFind=-1
            confFindVersion=-1
            confGenerate=-1
            confScript=-1
            confTests=-1
            confUse=-1
            etc=-1
            example=-1
            systemTests=-1
            unitTests=-1
            ;;
        --standard)
            minimal=1
            confSettings=1
            confDepends=1
            confComponents=-1
            confPackage=-1
            confFind=-1
            confFindVersion=-1
            confGenerate=-1
            confScript=-1
            confTests=-1
            confUse=-1
            etc=-1
            example=1
            tests=1
            unitTests=-1
            ;;

        --full)
            minimal=1
            confSettings=1
            confDepends=1
            confComponents=1
            confPackage=1
            confFind=1
            confFindVersion=1
            confGenerate=1
            confScript=1
            confTests=1
            confUse=1
            etc=1
            example=1
            tests=1
            unitTests=1
            ;;

        --conf-settings)
            confSettings=1
            ;;

        --no-conf-settings)
            confSettings=-1
            ;;

        --conf-depends)
            confDepends=1
            ;;

        --no-conf-depends)
            confDepends=-1
            ;;

        --conf-components)
            confComponents=1
            ;;

        --no-conf-components)
            confComponents=-1
            ;;

        --conf-package)
            confPackage=1
            ;;

        --no-conf-package)
            confPackage=-1
            ;;

        --conf-find)
            confFind=1
            ;;

        --no-conf-find)
            confFind=-1
            ;;

        --conf-find-version)
            confFindVersion=1
            ;;

        --no-conf-find-version)
            confFindVersion=-1
            ;;

        --conf-generate)
            confGenerate=1
            ;;

        --no-conf-generate)
            confGenerate=-1
            ;;

        --conf-script)
            confScript=1
            ;;

        --no-conf-script)
            confScript=-1
            ;;

        --conf-tests)
            confTests=1
            ;;

        --no-conf-tests)
            confTests=-1
            ;;

        --conf-use)
            confUse=1
            ;;

        --no-conf-use)
            confUse=-1
            ;;

        --etc)
            etc=1
            ;;

        --no-etc)
            etc=-1
            ;;

        --example)
            example=1
            ;;

        --no-example)
            example=-1
            ;;

        --tests)
            systemTests=1
            unitTests=1
            ;;

        --no-tests)
            systemTests=-1
            unitTests=-1
            confTests=-1
            ;;

        --system-tests)
            systemTests=1
            ;;

        --no-system-tests)
            systemTests=-1
            ;;

        --unit-tests)
            unitTests=1
            ;;

        --no-unit-tests)
            unitTests=-1
            ;;

        -*)
            echo "Invalid option $1!" 1>&2
            exit 1
            ;;

        *)
            if [ ! -z "$name" ]; then
                echo "More than one project name specified!" 1>&2
                exit 1
            fi
            name="$1"
            ;;
	esac
    shift
done

# dependsFile required if external packages should be found
if [ $packageNum -gt 0 ]; then
    confDepends=1
fi

# simplify template path
cwd=$(pwd)
cd $template
if [ $? -ne 0 ]; then
    echo "Invalid project template!"
    exit 1
fi
template=$(pwd)
cd $cwd

# request to create new project
if [ ! -z "$name" ]; then
    mode=0
    if [ -z "$root" ]; then
        root="$(pwd)/$name"
    fi
    if [ -e "$root" ]; then
        echo "Directory or file of name $root exists already." 1>&2
        echo "Please choose another project name or root directory using the -r option." 1>&2
        echo "If you want to modify an existing project, please provide the root directory using the -r option." 1>&2
        exit 1
    fi
    if [ -z "$description" ]; then
        echo "No project description given!"
        exit 1
    fi
# request to modify existing project
elif [ ! -z "$root" ]; then
    mode=1
    if [ ! -d "$root" ]; then
        echo "Project directory $root does not exist!" 1>&2
        echo "If you want to create a new project, please specify a project name." 1>&2
        exit 1
    fi
    if [ ! -z "$description" ]; then
        echo "Cannot modify description of existing project. Please edit root CMakeLists.txt file manually." 1>&2
        echo "Do not use option -d when attempting to modify an existing project." 1>&2
        exit 1
    fi
    if [ -z "$name" ]; then
        name=$(getProjectName "$root")
    fi
    if [ -z "$name" ]; then
        echo "Failed to determine project name! Expected to find expression 'NAME[ ]\+\"ProjectName\"' in root CMakeLists.txt file." 1>&2
        exit 1
    fi
# invalid usage
else
    echo "Either project name or project root must be specified!" 1>&2
    exit 1
fi

# verify that project name is valid
if [[ ! $name =~ ^[a-zA-Z0-9]+$ ]]; then
    echo "Invalid project name: $name" 1>&2
    echo "Project name may only consist of alphanumeric characters!" 1>&2
    echo "If you are attempting to modify an existent project, check whether the" 1>&2
    echo "project name is correctly extracted from the root CMakeLists.txt file." 1>&2
    exit 1
fi

# print template and root path
if [ $verbosity -gt 0 ]; then
    echo
    echo "Root directories:"
    echo "  Project:  $root"
    echo "  Template: $template"
    echo
fi

# ============================================================================
# main
# ============================================================================

# return value
retval=0

# sanitize project description for use in regular expression
description=${description//\//\\\/}
description=${description//\\/\\\\}
description=${description//"/\\"}

# ****************************************************************************
# \brief Add or modify project directory or file.
#
# Only the named directory or file is added or modified.
#
# \param [in] 1 The path of the directory or file relative to the template
#               or project root, respectively.

add ()
{
    local path="$1"

    # check existence of template
    if [ ! -e $template/$path ]; then
        echo "E $root/$path - template missing"
        return 1
    fi

    # handle case that path in project exists already
    if [ -e $root/$path ]; then
        if [ -d $template/$path ]; then
            if [ ! -d $root/$path ]; then
                # template is directory, but there is a file in the project
                echo "E $root/$path - not a directory"
                return 1
            else
                # directory already exists, nothing to do
                return 0
            fi
        elif [ -f $template/$path ]; then
            if [ ! -f $root/$path ]; then
                # template is file, but there is a directory in the project
                echo "E $root/$path - not a file"
                return 1
            fi
            # skip file if update of existing files is disabled
            if [ $update -eq 0 ]; then
                echo "S $root/$path"
                return 0
            fi
        fi
    fi

    # create (intermediate) directory
    local dir=''
    local base=''
 
    if [ -f "$template/$path" ]; then
        dir=`dirname $root/$path`
        base=`basename $root/$path`
    else
        dir="$root/$path"
    fi

    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        if [ $? -ne 0 ]; then
            echo "E $dir - failed to make directory"
            return 1
        else
            echo "A $dir"
        fi
    fi

    # add/update file
    if [ ! -z "$base" ]; then
        # project file does not exist yet
        if [ ! -f "$root/$path" ]; then
            # copy template and store copy of template required for update later
            if [ $verbosity -gt 0 ]; then
                cp "$template/$path" "$root/$path"
            else
                cp "$template/$path" "$root/$path" &> /dev/null
            fi
            if [ $? -ne 0 ]; then
                echo "E $root/$path - failed to add file"
                return 1
            else
                mkdir -p "$dir/.basis"
                if [ $verbosity -gt 0 ]; then
                    cp "$template/$path" "$dir/.basis/$base"
                else
                    cp "$template/$path" "$dir/.basis/$base" &> /dev/null
                fi
                if [ $? -ne 0 ]; then
                    echo "W $root/$path - file added, but failed to copy template to '.basis' (will not be able to update file later)"
                else
                    echo "A $root/$path"
                fi
            fi
            # alter project file, e.g., substitute for project name
            cat "$root/$path" \
                | sed "s/ReplaceByProjectName/$name/g" \
                | sed "s/ReplaceByProjectDescription/$description/g" \
                | sed "s/ReplaceByTemplateVersion/$version/g" \
              > "$root/$path.temp"
            if [ -f "$root/$path.temp" ]; then
                diff "$root/$path" "$root/$path.temp" &> /dev/null
                if [ $? -ne 0 ]; then
                    mv "$root/$path.temp" "$root/$path"
                    echo "M $root/$path"
                else
                    rm -f "$root/$path.temp"
                fi
            fi
        # update project file if backup of template used for creation exists
        elif [ -f "$dir/.basis/$base" ]; then
            # merge new template with project file using three-way diff
            if [ $verbosity -gt 0 ]; then
                diff3 -m "$root/$path" "$dir/.basis/$base" "$template/$path" > "$root/$path.update"
            else
                diff3 -m "$root/$path" "$dir/.basis/$base" "$template/$path" > "$root/$path.update" 2> /dev/null
            fi
            if [ $? -ne 0 ]; then
                echo "W $root/$path - failed to merge changes"
                cp "$template/$path" "$dir/$base.template" &> /dev/null
                return 1
            fi
            # check if anything has changed at all
            diff "$root/$path" "$root/$path.update" &> /dev/null
            if [ $? -ne 0 ]; then
                # backup current project file
                if [ $backup -ne 0 ]; then
                    if [ $verbosity -gt 0 ]; then
                        cp -f "$root/$path" "$dir/$base~"
                    else
                        cp -f "$root/$path" "$dir/$base~" &> /dev/null
                    fi
                    if [ $? -ne 0 ]; then
                        echo "S $root/$path - failed to backup file"
                        return 1
                    fi
                fi
                # replace project file by merged file
                if [ $verbosity -gt 0 ]; then
                    mv -f "$root/$path.update" "$root/$path"
                else
                    mv -f "$root/$path.update" "$root/$path" &> /dev/null
                fi
                if [ $? -ne 0 ]; then
                    echo "E $root/$path - failed to update file"
                    return 1
                fi
                # replace hidden template file
                if [ $verbosity -gt 0 ]; then
                    cp -f "$template/$path" "$dir/.basis/$base"
                    if [ $? -ne 0 ]; then
                        echo "U $root/$path - updated file, but failed to update hidden template"
                    else
                        echo "U $root/$path"
                    fi
                else
                    cp -f "$template/$path" "$dir/.basis/$base" &> /dev/null
                    echo "U $root/$path"
                fi
            else
                rm -f "$root/$path.update" &> /dev/null
            fi
        # cannot update files without copy of template used to create it
        else
            echo "S $root/$path - missing previous template"
            return 1
        fi
    fi

    return 0
}

# ****************************************************************************
# \brief Delete file or empty directory.
#
# \param [in] 1 Path relative to template or project root, respectively.

function del
{
    local path=$1

    # check existence of template
    if [ ! -e $template/$path ]; then
        echo "E $root/$path - template missing"
        return 1
    fi

    # delete existing directory if empty only
    if [ -d "$root/$path" ]; then
        if [ $verbosity -gt 0 ]; then
            rmdir "$root/$path"
        else
            rmdir "$root/$path" &> /dev/null
        fi
        if [ $? -ne 0 ]; then
            echo "E $root/$path - failed to remove directory"
            return 1
        else
            echo "D $root/$path"
        fi
    # delete existing file and copy of template
    elif [ -f "$root/$path" ]; then
        # check if project file differs from template
        diff "$root/$path" "$template/$path"
        if [ $? -ne 0 -a $force -eq 0 ]; then
            echo "S $root/$path - file was modified; use --force to force deletion"
            return 1
        fi
        # delete copy of template and '.basis' directory if then empty
        local dir=`dirname $root/$path`
        local base=`basename $root/$path`

        rm -f "$dir/.basis/$base" &> /dev/null
        if [[ $(ls "$dir/.basis" 2>&1) == '' ]]; then
            rm -rf "$dir/.basis" # there might be hidden subdirectories from the RCS
        fi
        # delete project file
        if [ $verbosity -gt 0 ]; then
            rm -f "$root/$path"
        else
            rm -f "$root/$path" &> /dev/null
        fi
        if [ $? -ne 0 ]; then
            echo "E $root/$path - failed to remove file"
            return 1
        else
            echo "D $root/$path"
        fi
    fi

    return 0
}

# ****************************************************************************
# \brief Add or delete file depending on option given.
#
# \param [in] 1 Switch option. If > 0, the file is added or updated.
#               If < 0, the file is deleted. Otherwise, nothing is done.
# \param [in] 2 File path relative to tempate or project root, respectively.

function addordel
{
    local switch=$1
    local path=$2

    if [ $switch -gt 0 ]; then
        add $path || return 1
    elif [ $switch -lt 0 ]; then
        del $path || return 1
    fi

    return 0
}

# ----------------------------------------------------------------------------
# modify project files

if [ $mode -eq 1 ]; then
    msg="Modifying project"
else
    msg="Creating project"
fi
echo "$msg..."

# minimal project structure
if [ $minimal -gt 0 ]; then
    add "AUTHORS"            || retval=1
    add "README"             || retval=1
    add "INSTALL"            || retval=1
    add "LICENSE"            || retval=1
    add "CMakeLists.txt"     || retval=1
    add "doc/CMakeLists.txt" || retval=1
    add "src/CMakeLists.txt" || retval=1
fi

# additional configuration files
addordel $confDepends     "config/$dependsFile"           || retval=1
addordel $confSettings    "config/Settings.cmake"         || retval=1
addordel $confComponents  "config/Components.cmake"       || retval=1
addordel $confPackage     "config/Package.cmake"          || retval=1
addordel $confFind        "config/Config.cmake.in"        || retval=1
addordel $confFind        "config/ConfigBuild.cmake"      || retval=1
addordel $confFind        "config/ConfigInstall.cmake"    || retval=1
addordel $confFindVersion "config/ConfigVersion.cmake.in" || retval=1
addordel $confGenerate    "config/GenerateConfig.cmake"   || retval=1
addordel $confScript      "config/ScriptConfig.cmake.in"  || retval=1
addordel $confTests       "config/CTestCustom.cmake.in"   || retval=1
addordel $confUse         "config/Use.cmake.in"           || retval=1

if [ -d "$root/config" ]; then
    if [[ $(ls "$root/config") == '' ]]; then
        rm -rf "$root/config" &> /dev/null
    fi
fi

# software configuration data
addordel $etc "etc/CMakeLists.txt" || retval=1
addordel $etc "etc"                || retval=1

# testing tree
addordel $systemTests "test/system/CMakeLists.txt" || retval=1
addordel $unitTests   "test/unit/CMakeLists.txt"   || retval=1

if [ $systemTests -gt 0 -o $unitTests -gt 0 ]; then
    add "CTestConfig.cmake"   || retval=1
    add "test/CMakeLists.txt" || retval=1
    add "test/data"           || retval=1
    add "test/expected"       || retval=1
elif [ $systemTests -lt 0 -a $unitTests -lt 0 ]; then
    del "CTestConfig.cmake"   || retval=1
    del "test/CMakeLists.txt" || retval=1
    del "test/data"           || retval=1
    del "test/expected"       || retval=1
    del "test"                || retval=1
fi

# example
addordel $example "example/CMakeLists.txt" || retval=1
addordel $example "example"                || retval=1

# done
if [ $retval -ne 0 ]; then
    echo "$msg... - errors occurred"
else
    echo "$msg... - done"
fi

# ****************************************************************************
# \brief Append find_package () commands to CMake configuration file.
#
# \param [in] 1 The path to the CMake configuration file.
# \param [in] 2 The name of the package.
# \param [in] 3 Whether this package is required.
# \param [in] 4 Whether to use uppercase only prefix for variables.
# \param [in] 5 Whether this package provides a <name>Use.cmake file.
# \param [in] 6 Prefix to use for package variables. Defaults to package name.

findPackage ()
{
    local file=$1
    local package=$2
    local required=$3
    local uppercasePrefix=$4
    local useFile=$5
    local prefix=$package

    if [ $# -gt 5 ]; then
        prefix=$6
    fi

    if [ $uppercasePrefix -ne 0 ]; then
        prefix=$(echo $prefix | tr [:lower:] [:upper:])
    fi

    echo >> $file
    echo "# ----------------------------------------------------------------------------" >> $file
    echo "# $package" >> $file
    echo "# ----------------------------------------------------------------------------" >> $file
    echo >> $file
    if [ $required -ne 0 ]; then
    echo "find_package (${package} REQUIRED)" >> $file
    else
    echo "find_package (${package})" >> $file
    fi
    echo >> $file
    echo "if (${prefix}_FOUND)" >> $file
    if [ $useFile -ne 0 ]; then
    echo "  include (\${${prefix}_USE_FILE})" >> $file
    else
    echo "  if (${prefix}_INCLUDE_DIRS)" >> $file
    echo "    include_directories (\${${prefix}_INCLUDE_DIRS})" >> $file
    echo "  elseif (${prefix}_INCLUDE_DIR)" >> $file
    echo "    include_directories (\${${prefix}_INCLUDE_DIR})" >> $file
    echo "  endif ()" >> $file
    # \note According to an email on the CMake mailing list, it is not a good idea
    #       to use link_directories () any more given that the arguments to
    #       target_link_libraries () are absolute paths to the library files.
    #echo >> $file
    #echo "  if (${prefix}_LIBRARY_DIRS)" >> $file
    #echo "    link_directories (\${${prefix}_LIBRARY_DIRS})" >> $file
    #echo "  elseif (${prefix}_LIBRARY_DIR)" >> $file
    #echo "    link_directories (\${${prefix}_LIBRARY_DIR})" >> $file
    #echo "  endif ()" >> $file
    fi
    if [ $required -ne 0 ]; then
    echo "else ()" >> $file
    echo "  # raise fatal error in case Find${package}.cmake did not do it" >> $file
    echo "  message (FATAL_ERROR \"Package ${package} not found.\")" >> $file
    fi
    echo "endif ()" >> $file

    echo "M $file - added entry for package $package"
}

# ----------------------------------------------------------------------------
# modify dependencies

if [ $packageNum -gt 0 ]; then
    echo
    echo "Adding dependencies..."

    dependsFilePath=$root/config/$dependsFile

    if [ ! -f "$dependsFilePath" ]; then
        echo "Dependencies configuration file $dependsFile not found!" 1>&2
        exit 1
    fi

    idx=0
    while [ $idx -lt $packageNum ]
    do
        pkg="${packageNames[$idx]}"
        required=${packageRequired[$idx]}

        case "$pkg" in
            # use package name for both find_package ()
            # and <pkg>_VARIABLE variable names
            # -> package provides <PKG>_USE_FILE
            ITK)
                findPackage $dependsFilePath $pkg $required 0 1
                ;;
            # use package name for find_package ()
            # and <PKG>_VARIABLE variable names
            Matlab)
                findPackage $dependsFilePath $pkg $required 1 0
                ;;
            # default, use package name for both find_package ()
            # and <pkg>_VARIABLE variable names
            *)
                findPackage $dependsFilePath $pkg $required 0 0
                ;;
        esac

        ((idx++))
    done

    echo "Adding dependencies... - done"
fi

# ============================================================================
# clean up
# ============================================================================

# ****************************************************************************
# \brief Clean temporary files.

function cleanTemp
{
    # *.template
    for file in $(find "$root" -type f -name '*.template'); do
        rm -f "$file"
    done
    # *.update
    for file in $(find "$root" -type f -name '*.update'); do
        rm -f "$file"
    done
}

# ****************************************************************************
# \brief Remove hidden copies of template files.

function cleanHidden
{
    # .basis
    for dir in $(find "$root" -type d -name '.basis'); do
        rm -rf "$dir"
    done
}

# ----------------------------------------------------------------------------
# do the clean up

if [ $clean -ne 0 -o $cleanAll -ne 0 ]; then
    msg="Cleaning up"
    echo "$msg..."
fi

if [ $clean -ne 0 -o $cleanAll -ne 0 ]; then
    cleanTemp
fi
if [ $cleanAll -ne 0 ]; then
    cleanHidden
fi

if [ $clean -ne 0 -o $cleanAll -ne 0 ]; then
    echo "$msg... - done"
fi

# ============================================================================
# done
# ============================================================================

echo
if [ $mode -eq 1 ]; then
    msg="Project \"$name\" modified"
else
    msg="Project \"$name\" created"
fi
if [ $retval -ne 0 ]; then
    echo "$msg with errors" 1>&2
else
    echo "$msg successfully"
fi

exit $retval
