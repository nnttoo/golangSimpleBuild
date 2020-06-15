#!/bin/sh

#export for npm bin directory
#export PATH="$(pwd)/node_modules/.bin:$PATH"


#set current directory as GOPATH
export GOPATH=$GOPATH:$(pwd)

BINFILE=testmongodb
TARGETDIRNAME=output
 
builder(){
    TARGETDIR=$2
    case "$1" in
    "build")  
        rice embed-go; 
        go build -o "${TARGETDIR}/${BINFILE}"
        rm rice-box.go
        ;;

    "run")
        cd "../"
        ${TARGETDIRNAME}/${BINFILE}
        ;;
    "runscript")
        go run main.go
        ;;

    "brun")
        #build and run
        builder build $TARGETDIR
        builder run $TARGETDIR
        ;;
    "win")
        #comand for create icon
        x86_64-w64-mingw32-windres icon.rc -o icon_windows.syso 

        rice embed-go
        GOOS=windows \
        GOARCH=amd64 \
        CGO_ENABLED=1 \
        CC=x86_64-w64-mingw32-gcc \
        CXX=x86_64-w64-mingw32-g++ \
        go build -ldflags "-H windowsgui" \
        -o ${TARGETDIR}/${BINFILE}.exe
        rm rice-box.go
        rm icon_windows.syso
        ;;


    "win32")
        #command for create icon
        i686-w64-mingw32-windres icon.rc -o icon_windows.syso

        rice embed-go
        GOOS=windows \
        GOARCH=386 \
        CGO_ENABLED=1 \
        CC=i686-w64-mingw32-gcc \
        CXX=i686-w64-mingw32-g++ \
        go build -ldflags "-H windowsgui" \
        -o ${TARGETDIR}/win32/${BINFILE}.exe
        rm rice-box.go
        rm icon_windows.syso
        ;;

    "raspi")
        rice embed-go
        env GOOS=linux  \
        GOARCH=arm GOARM=7  \
        CGO_ENABLED=1  \
        CC=arm-linux-gnueabihf-gcc  \
        go build --tags "linux" \
        -o  ${TARGETDIR}/raspi/${BINFILE}
        rm rice-box.go
        ;;


    "mac")
        GOOS=linux GOARCH=amd64 \
        go build  -o ${TARGETDIR}/${BINFILE}_darwin
        ;;

    "buildall")
        builder build
        builder win
        builder win32
        builder raspi
        builder make
        ;;

    "clean")
        rm -f ${TARGETDIR}/${BINFILE}
        rm -f ${TARGETDIR}/${BINFILE}.exe
        rm -f ${TARGETDIR}/win32/${BINFILE}.exe
        rm -f ${TARGETDIR}/raspi/${BINFILE}
        rm -f ${TARGETDIR}/${BINFILE}_darwin
        rm -fr ${TARGETDIR}/win32/
        rm -fr ${TARGETDIR}/raspi/
        ;;
 

    esac
} 

cd ./src 

DEFARG=""
if  [ -z "$1" ]
then
    DEFARG="build"
else
    DEFARG=$1
fi
echo $DEFARG
builder $DEFARG "../"$TARGETDIRNAME