# RedisAll

```
# 一定要先调整编码
dnf install langpacks-en glibc-all-langpacks -y && \
localectl set-locale LANG=en_US.UTF-8 && \
localectl

vi /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
	# 添加这两项 

source /etc/environment

vi /etc/profile.d/utf8.sh 
export LANG="en_US.utf-8"
export LC_ALL="en_US.utf-8"
export LANGUAGE="en_US"


# almalinux 8
dnf makecache --refresh && \
dnf update -y && \
dnf install -y epel-release && \
dnf update -y && \
dnf --enablerepo=powertools install perl-IPC-Run -y && \
pip3 install conan && \
dnf install -y tar p7zip libsodium curl net-tools cronie lsof git wget yum-utils make gcc gcc-c++ clang openssl-devel bzip2-devel libffi-devel zlib-devel libpng-devel boost-devel systemd-devel ntfsprogs ntfs-3g

curl https://sh.rustup.rs -sSf | sh && \
source "$HOME/.cargo/env"
	# RedisJSON 要用 rust 编译
	
	
wget https://github.com/Kitware/CMake/releases/download/v3.23.4/cmake-3.23.4.tar.gz && \
tar xvf cmake-3.23.4.tar.gz && \
cd cmake-3.23.4 && \
./bootstrap --prefix=/usr && \
make -j 8 && \
make install && \
ln -s /usr/local/cmake/3.23.4/bin/cmake /usr/bin/cmake && \
ln -s /usr/local/cmake/3.23.4/bin/cpack /usr/bin/cpack && \
ln -s /usr/local/cmake/3.23.4/bin/ctest /usr/bin/ctest	


mkdir build && \
cd build && \
../configure --prefix=/usr && \
make -j 4 && \
make install && \
ln -s /usr/local/cmake/3.23.4/bin/cmake /usr/bin/cmake && \
ln -s /usr/local/cmake/3.23.4/bin/cpack /usr/bin/cpack && \
ln -s /usr/local/cmake/3.23.4/bin/ctest /usr/bin/ctest	
	# 安装cmake
	
	
git clone --recursive https://github.com/RedisJSON/RedisJSON.git && \
cd RedisJSON && \
./sbin/setup

	vi /etc/profile.d/utf8.sh
		# 好像是这个把 utf8 环境搞坏的 
export LANG="en_US.utf-8"
export LC_ALL="en_US.utf-8"
export LANGUAGE="en_US"
			# 内容一定要先改成这样

cargo build --release


git clone --recursive https://github.com/RediSearch/RediSearch.git && \
cd RediSearch && \
pip3 install conan && \
./sbin/setup && \
make setup && \
make clean ALL=1 && \ 
make build SLOW=1 VERBOSE=1
	https://redis.io/docs/stack/search/development/
	/root/RediSearch/bin/linux-x64-release/search/redisearch.so
make run DEBUG=1
	# 必须已安装 redis-server
	# 可以用 GDB 下断点

vi /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
	# 添加这两项

source /etc/environment

gdb -ex r --args redis-server --loadmodule /root/RediSearch/bin/linux-x64-release/search/redisearch.so --loadmodule /root/RedisJSON/bin/linux-x64-release/rejson.so
	# https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/gdb.html
	# 成功跑起来以后 ctrl + Z 回到 gdb

/root/RediSearch/src/tokenize.c
	GetTokenizer

(gdb) break GetTokenizer
(gdb) info b
(gdb) r
	# 重新运行

redis-cli
	# 这里执行中文搜索，可以成功触发断点

./autogen.sh
make install
friso -init /usr/local/etc/friso/friso.ini
歧义和同义词:研究生命起源，混合词: 做B超检查身体

"-lm" linux vscode 的 gcc 配置要加一个 -lm 参数

next_mmseg_token
next_complex_cjk


```



## NGram



```
/root/RediSearch/deps/friso/friso_UTF8.c
#define FRISO_CJK_CHK_C
#define FRISO_CJK_CHK_J
	# 开启 JP 字符检测
	
/root/RediSearch/deps/friso/friso.h
	# 147 行  } friso_task_entry;
	
	char text2[8192];
    char NGram[8192];
    uint_t currPos;
		# 结构体后面加这三行 

/root/RediSearch/deps/friso/friso.c
	next_mmseg_token(
		# 这个函数整个替换成下面这样

// http://www.unicode.org/cgi-bin/GetUnihanData.pl?codepoint=%E4%B8%A5
// https://www.sqlite.org/c3ref/create_function.html
// https://github.com/schuyler/levenshtein

# define min(x, y) ((x) < (y) ? (x) : (y))
# define max(x, y) ((x) > (y) ? (x) : (y))


static int utf8len(char* c) {
    unsigned char c1 = c[0];
    int len = -1;
    if ((c1 & 0x80) == 0) {  // 0b10000000
        len = 1;
    }
    else if ((c1 & 0xF0) == 0xF0) {  // 0b11110000
        len = 4;
    }
    else if ((c1 & 0xE0) == 0xE0) {  // 0b11100000
        len = 3;
    }
    else if ((c1 & 0xC0) == 0xC0) {  // 0b11000000 
        len = 2;
    }
    else {
        return -1;
    }
    return len;
}

/*
** Assuming z points to the first byte of a UTF-8 character,
** advance z to point to the first byte of the next UTF-8 character.
*/
static int utf8strlen(char* str) {
    int len;
    const unsigned char* z = str;
    if (z == 0) {
        return -1;
    }
    len = 0;
    while (*z) {
        len++;
        //SQLITE_SKIP_UTF8(z);
        if ((*(z++)) >= 0xc0) {
            while ((*z & 0xc0) == 0x80) { z++; }
        }
    }
    return len;
}

// 
/*
1 0xxxxxxx
2 110xxxxx 10xxxxxx 0xC0 0x80
3 1110xxxx 10xxxxxx 10xxxxxx
4 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
5 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
6 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
*/
// 
static char* nextc(char* z) {
    if (z == 0) { return 0; }
    if (*z == 0) {
        return 0;
    }
    ++z;
    while ((*z & 0xC0) == 0x80) { ++z; }  // 
    return z;
}

static char* at(char* z, int pos) {
    char* t = z;
    int i;
    for (i = 0; i < pos; i++) {
        t = nextc(t);
    }
    return t;
}

static int utf8eq(char* c1, char* c2) {
    int i;
    if (c1 == 0 || c2 == 0 || *c1 == 0 || *c2 == 0) {
        return -1;
    }
    int len1 = utf8len(c1);
    int len2 = utf8len(c2);
    if (len1 != len2) {
        return 0;
    }
    else {
        for (i = 0; i < len1; i++) {
            if (c1[i] != c2[i]) {
                return 0;
            }
        }
    }
    return 1;
}



/* {{{ get the next segmentation.
 *     and also this is the friso enterface function.
 *
 * @param     friso.
 * @param    config.
 * @return    task.
 */
FRISO_API friso_token_t next_mmseg_token( 
        friso_t friso, 
        friso_config_t config, 
        friso_task_t task ) 
{

    /**/
    if (task->idx == 0) { // 
        memset(task->NGram, 0, 8192);
        memset(task->text2, 0, 8192);
        task->currPos = 0;
        sprintf(task->NGram, "");
        sprintf(task->text2, task->text);

        //assert(utf8eq(task->text, task->text2) == 1);

        char tmp[8192] = { 0 };
        char ngram[8192] = { 0 };
        //memcpy( tmp, at(task->text2, 0), at(task->text2, 1) - at(task->text2, 0));
        //printf("%s", tmp);

        int curPos = 0;

        int len = utf8strlen(task->text2);      // 

        for (int i = 0; i < len; i++) {       // 
            for (int j = 0; j < 6; j++) {      // 
                if (i + j < len) {
                    char * starti = at(task->text2, i);
                    char * startj = at(task->text2, i+j);
                    int lenj = utf8len(startj);
                    char* end = startj + lenj;
                    int bytes = end - starti;
                    memcpy(tmp, starti, bytes);

                    sprintf(ngram + curPos, "%s", tmp);
                    //printf("%s ", ngram + curPos);
                    
                    curPos = curPos + bytes + 1;
                    memset(tmp, 0, 8192);

                }
                else {
                    break;
                }
            }
        }

        memcpy(task->NGram, ngram, 8192);

        int findNext = 0;
        for (int k = 0; k < 8192 - 1; k++) {
            
            if (ngram[k] == '\0' && ngram[k + 1] == '\0') {
                break;
            }

            if (findNext) {
                if (ngram[k] == '\0' && ngram[k + 1] != '\0') {
                    findNext = 0;
                    continue;
                }
                else {
                    continue;
                }
                
            }
            
            if (ngram[k] != '\0') {
                //printf("\n->%s ", & ngram[k]);
                findNext = 1;
                
                int len2 = strlen(&task->NGram[k]);
                memcpy(task->token->word, &task->NGram[k], len2);
                //task->token->type = lex->type;
                task->token->length = len2;
                task->token->rlen = len2;
                task->token->word[len2] = '\0';

                task->currPos = k;

                task->idx = 1;

                return task->token;

            }
        }
        
        //printf(":");

        //int len2 = strlen(&task->NGram[0]);
        //memcpy(task->token->word, &task->NGram[0], len2);
        ////task->token->type = lex->type;
        //task->token->length = len2;
        //task->token->rlen = len2;
        //task->token->word[len2] = '\0';

        //task->currPos = 0 + len2 + 1;

        //task->idx = 1;

        //return task->token;

    }
    else {

        int findNext = 1;
        for (int k = task->currPos; k < 8192 - 1; k++) {

            if (task->NGram[k] == '\0' && task->NGram[k + 1] == '\0') {
                return NULL;
                //break;
            }

            if (findNext) {
                if (task->NGram[k] == '\0' && task->NGram[k + 1] != '\0') {
                    findNext = 0;
                    continue;
                }
                else {
                    continue;
                }

            }

            if (task->NGram[k] != '\0') {
                //printf("\n->%s ", &task->NGram[k]);
                findNext = 1;

                int len2 = strlen(&task->NGram[k]);
                memcpy(task->token->word, &task->NGram[k], len2);
                //task->token->type = lex->type;
                task->token->length = len2;
                task->token->rlen = len2;
                task->token->word[len2] = '\0';

                task->currPos = k;

                task->idx = 1;

                return task->token;

            }
        }
    }



    uint_t j, len = 0;
    string_buffer_t sb = NULL;
    lex_entry_t lex = NULL, tmp = NULL, sword = NULL;

    /* {{{ task word pool check */
    if ( ! link_list_empty( task->pool ) ) {
```



# building 

```
git clone --recursive https://github.com/dlxj/RedisAll.git && \
cd RedisAll && \
make USE_SYSTEMD=yes BUILD_TLS=yes


```







