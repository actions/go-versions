set -e

GO_VERSION={0}
ARCH={1}

GO_TOOLCACHE_PATH=$AGENT_TOOLSDIRECTORY/go
GO_TOOLCACHE_VERSION_PATH=$GO_TOOLCACHE_PATH/$GO_VERSION
GO_TOOLCACHE_VERSION_ARCH_PATH=$GO_TOOLCACHE_VERSION_PATH/$ARCH

echo "Check if Go hostedtoolcache folder exist..."
if [ ! -d $GO_TOOLCACHE_PATH ]; then
    mkdir -p $GO_TOOLCACHE_PATH
fi

echo "Delete Go $GO_VERSION if installed"
rm -rf $GO_TOOLCACHE_VERSION_PATH

echo "Create Go $GO_VERSION folder"
mkdir -p $GO_TOOLCACHE_VERSION_ARCH_PATH

echo "Copy Go binaries to hostedtoolcache folder"
cp -R ./* $GO_TOOLCACHE_VERSION_ARCH_PATH
rm $GO_TOOLCACHE_VERSION_ARCH_PATH/setup.sh

echo "Create complete file"
touch $GO_TOOLCACHE_VERSION_PATH/$ARCH.complete
