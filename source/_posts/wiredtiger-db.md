---
title: WIREDTIGER
date: 2021-06-03 18:50:11
tags: wiredtiger
toc: true
categories: database
---

Wiredtiger数据库的简单整理和总结。

<!-- more -->

### 资源

文档：[link](http://source.wiredtiger.com/)

GitHub：[link](https://github.com/wiredtiger/wiredtiger)

公众号文章：MongoDB中文社区对wiredtiger的一些介绍。[link](https://mp.weixin.qq.com/s?__biz=MzU4MTA2NTM0Ng==&mid=2247486377&idx=1&sn=307b14fd7ae11778037ea26b0c3f1c64&chksm=fd4c0444ca3b8d52cab16ca5867e8d2ca53be691816ae02d9b4c4674a9a2a9366eab8dcd30d3&scene=21#wechat_redirect)

wiredtiger演讲， 2015：[link](https://www.mongodb.com/presentations/a-technical-introduction-to-wiredtiger)


### [编译](http://source.wiredtiger.com/3.2.1/build-posix.html)

几个注意事项：

1. 若需使用内置压缩引擎，需在编译时开启。内置的引擎包括lz4、snappy、zlib、zstd等，此外还可通过**WT_COMPRESSOR**来自定义压缩引擎（[link](http://source.wiredtiger.com/3.2.1/compression.html)）。
2. 使用**-–with-builtins=xxx**可以将压缩引擎打包到wiredtiger中，可避免运行时加载额外的库文件。
3. 若需使用 python 或 java api，需在编译期开启。

### 使用

1. 数据库文件介绍

   wiredtiger数据库名称依赖于 wiredtiger_open 或环境变量 WIREDTIGER_HOME，数据库以文件夹为单位组织，其内包含多个文件。优先使用wiredtiger_open指定，若环境变量未指定，则使用当前文件夹。文件夹内各个文件的基本介绍如下：

   |                文件名                |                             作用                             |
   | :----------------------------------: | :----------------------------------------------------------: |
   |            table_name.wt             |             用于B树的表数据存储，一个表一个文件              |
   |            table_name.lsm            |            用于lsm树的表数据存储，一个表一个文件             |
   |            index_name.wti            |           用于B树的索引数据存储，一个索引一个文件            |
   |           WiredTiger.lock            |      运行实例锁，防止多个进程同时连接一个WiredTiger实例      |
   |              WiredTiger              |          内含当前数据库的WiredTiger版本号和编译时间          |
   |            WiredTiger.wt             | 存储的是所有集合（包含系统自带的集合）相关数据文件和索引文件的checkpoint信息 |
   |           WiredTigerLAS.wt           | 内存里面lookaside table的持久化的数据,当对一个page进行reconcile时，如果系统中还有之前的读操作正在访问此page上的修改数据，则会将这些数据保存到lookaside table；当page再被读时，可以利用此lookaside table中的数据重新构建内存page |
   |          WiredTiger.turtle           | 存储的是WiredTiger.wt这个文件的checkpoint数据信息。相当于对保存有所有集合checkpoints信息的文件WiredTiger.wt又进行了一次checkpoint |
   | WiredTigerLog.n、WiredTigerPreplog.n |                n为整数，左端以0补齐，日志文件                |

2. 主要的操作对象

   - [connection](http://source.wiredtiger.com/3.2.1/struct_w_t___c_o_n_n_e_c_t_i_o_n.html#af535c517df851eeac8ebf3594d40b545)：一个数据库的连接，connection中包含的所有方法都是线程安全的。程序停止前需要显示关闭connection以保证数据落盘，关闭connection同时将释放在其上打开的所有资源，若未关闭且未开启日志恢复功能，可能造成数据丢失。

   - [session](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html)：数据库操作的上下文，在connection之上打开，每个线程打开一个session用于数据库操作，使用session->close关闭；

   - [cursor](http://source.wiredtiger.com/3.2.1/struct_w_t___c_u_r_s_o_r.html)：数据库数据之上的游标，对应一个数据位置，可通过访问对应位置的key和value，可使用search、search_near将游标放置到指定位置，可通过对cursor设置key或key和value来执行删除或插入、更新等操作，使用cursor->close关闭并释放资源；
   
3. wiredtiger中的表和索引

   wiredtiger是key-value数据库，但支持更复杂的表结构，但是复杂的表结构同样是基于key-value组织的。

   ```c
   // open connection first
   // then open a session on connection
   
   // create table
   session.create("table:poptable",
                  "key_format=r,value_format=5sHQ,"
                  "columns=(id,country,year,population),colgroups=(main,population)");
   
   // create colgroups
   session.create("colgroup:poptable:main", "columns=(country,year,population)");
   session.create("colgroup:poptable:population", "columns=(population)");
   
   // create index
   session.create("index:poptable:country", "columns=(country)");
   ```

   - 数据类型：wiredtiger细分了多种数据类型，包括int8_t(b)、uint8_t(B), int16_t(h), ..., int64_t(q), uint64_t(Q), char[] with fixed length(s), char[] with '\\0' terminated(S), raw byte array WT_ITEM*(u)等。同类型数据保证数据能够按自然顺序增序排序。使用WT_ITEM可以实现二进制数据读写。

   - 创建表的过程：需要指明key类型，value类型，columns按照key-value的顺序依次指明列名。使用colgroups可以将一部分数据聚集在一个文件中存储，在某些场景下可以单独载入该文件以提高效率。表数据将以key有序排列。

   - 索引：wiredtiger将自动在插入和删除过程中维护索引项目。但是索引是只读的，无法对其进行更新和删改。可以在创建过程中指定索引不可变，此后主表将不会在增删改过程中维护该索引。

     索引将按照其各个项目依次有序排列，对于整数类型，其以自然顺序升序有序，字符串类型按字典序升序有序。查询过程可使用投影访问全表的全部或部分数据。

4. 增删查改

   wiredtiger 的增删查改操作基于 [cursor](http://source.wiredtiger.com/3.2.1/cursors.html)。cursor保存了对应位置的数据资源，且cursor占用将导致对应页面无法驱逐。可通过[WT_CURSOR::reset](http://source.wiredtiger.com/3.2.1/struct_w_t___c_u_r_s_o_r.html#afc1b42c22c9c85e1ba08ce3b34437565) 重置游标并释放资源。

   - raw模式数据

     于[WT_SESSION::open_cursor](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#afb5b4a69c2c5cafe411b2b04fdc1c75d) 指明raw模式。

     通过[WT_CURSOR::get_key](http://source.wiredtiger.com/3.2.1/struct_w_t___c_u_r_s_o_r.html#af19f6f9d9c7fc248ab38879032620b2f)、[WT_CURSOR::get_value](http://source.wiredtiger.com/3.2.1/struct_w_t___c_u_r_s_o_r.html#af85364a5af50b95bbc46c82e72f75c01)、 [WT_CURSOR::set_key](http://source.wiredtiger.com/3.2.1/struct_w_t___c_u_r_s_o_r.html#ad1088d719df40babc1f57d086691ebdc)、[WT_CURSOR::set_value](http://source.wiredtiger.com/3.2.1/struct_w_t___c_u_r_s_o_r.html#a27f7cbd0cd3e561f6a145704813ad64c) 读写单个WT_ITEM类型的key和value。

     使用[WT_EXTENSION_API::struct_pack](http://source.wiredtiger.com/3.2.1/struct_w_t___e_x_t_e_n_s_i_o_n___a_p_i.html#a353dd240d0f7b32910d1bb97c0762ee8) 以及wiredtiger_struct_pack、wiredtiger_struct_unpack对raw item解析。
   
   - 普通数据，
   
     ```c
     cursor->set_key(cursor, key1, key2, ..., keym);
  cursor->get_key(cursor, &key1, &ke2, ..., &keym);
     cursor->set_value(cursor, val1, val2, ..., valn);
  cursor->get_value(cursor, &val1, &val2, ..., valn);
     ```
   
   - 更新、插入、删除、查找
   
     ```c
     cursor->insert(cursor)；// 若设置overwrite=false，无法insert已有数据；
     cursor->update(cursor); // 若设置overwrite=false，需使用update更新；
     cursor->remove(cursor);
     cursor->search(cursor); // 精确查找
     int pos;
     cursor->search_near(cursor, &pos); // 找到与目标最邻近的cursor位置，pos以确定当前与目标的相对位置
     ```
     
   - 顺序遍历
   
     ```c
     // 重置cursor位置
     cursor->reset(cursor);
     while (cursor->next(cursor) == 0) { // reset cursor后，第一次调用next将使cursor定位到第一条数据的位置，直到没有数据返回非0
         // read data
     }
     
     // 重置cursor位置
     cursor->reset(cursor);
     while (cursor->prev(cursor) == 0) { // reset cursor后，第一次调用prev将使cursor定位到最后一条数据的位置，直到没有数据返回非0
         // read data
     }
     ```
   
     
   
5. btree和lsm-tree

   wiredtiger同时支持btree和lsm-tree两种数据结构。可在创建表、索引的过程中指定其使用btree或lsm-tree。对btree，当cache不足，性能将显著下降。

   ```c
   // create a table with lsm tree
   // you can create index as the same way
   session->create(session, "table:bucket", "type=lsm,key_format=S,value_format=S");
   ```

   实际使用中，每个表在数据库文件夹中会有大量的小文件，而非btree那样一个文件。

6. 数据压缩

   wiredtiger内置支持一些数据压缩引擎，但需要在编译过程中将其编译在内，包括lz4，snappy，zlib，zstd。[link](http://source.wiredtiger.com/3.2.1/compression.html)

   lz4的使用方法如下，其他类似：

   ```c
   // 若独立编译了libwiredtiger_lz4.so，需要在wired_open时加载该插件
   wiredtiger_open(home, NULL,
         "create,"
         "extensions=[/path/to/libwiredtiger_lz4.so]",
         &conn);
   // 在创建表、索引等对象时，指定块压缩引擎
   session->create(
         session, "table:mytable", "block_compressor=lz4,key_format=S,value_format=S");
   ```

   此外，还可以自定义压缩引擎。

7. 事务

   MVCC，乐观并发，轻量级。支持ACID：最大程度的隔离支持快照隔离、通过日志和检查点执行事务更新、对于未提交事务必维持在内存中，直到事务提交才写到日志中。

   事务接口位于 [WT_SESSION](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html)。

   通过[WT_SESSION::begin_transaction](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a7e26b16b26b5870498752322fad790bf) 开启事务，随后在该session上发生的操作将属于事务的一部分。

   通过[WT_SESSION::commit_transaction](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a712226eca5ade5bd123026c624468fa2)提交事务。

   通过[WT_SESSION::rollback_transaction](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#ab45f521464ad9e54d9b15efc2ffe20a1)回滚事务。

8. [错误处理](http://source.wiredtiger.com/3.2.1/error_handling.html)

   wiredtiger api 通过返回一个int值来标识操作的正确性，若返回值为0，标识操作正确执行，否则将返回一系列非零的错误码标识操作错误类型。

   使用 [WT_SESSION::strerror](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#abe03ccb716e097ed1bb4d42eb733c1f9) 和 [wiredtiger_strerror](http://source.wiredtiger.com/3.2.1/group__wt.html#gae8bf720ddb4a7a7390b70424594c40fd) 以翻译错误信息：

   ```c
   ret = error_code_of_wiredtiger_return_value;
   printf("error message is %s\n", wiredtiger_strerror(ret));
   ```


### 配置

wiredtiger使用配置字符串进行配置，配置对象包括：connection、session、cursor、table、index等，在打开或创建新的对象的同时传入配置字符串，或使用api在运行时使用配置项。

1. 对connection使用配置，在wiredtiger_open接口中传入配置字符串，或使用reconfigure重新配置，详细配置内容见[link](http://source.wiredtiger.com/3.2.1/group__wt.html#gacbe8d118f978f5bfc8ccb4c77c9e8813)，一个常见的配置如下：

   ```c
   // configuration example
   wiredtiger_open(
         db_home_path, NULL, "create,cache_size=5GB,log=(enabled,recover=on),statistics=(all)", &conn);
   ```

   下面简要介绍一些常用的：

   |                             配置                             |                             备注                             |
   | :----------------------------------------------------------: | :----------------------------------------------------------: |
   |                        cache_size=1GB                        | 最大堆内存缓存，用于存放wiredtiger树节点等内容，范围[1M, 10TB]，默认100M |
   |               checkpoint=(log_size=0, wait=0)                |                        检查点周期配置                        |
   |                            create                            |         若数据库不存在，则创建该数据库，默认为false          |
   |            eviction=(threads_max=8,threads_min=1)            |             页面驱逐线程数量，取决于驱逐任务负载             |
   |                       eviction_target                        |        缓存中数据量达到指定比例或数值后将触发页面驱逐        |
   |                     eviction_trigger=95                      | 缓存中数据量达到指定比例或数值后将触发应用线程同时参与页面驱逐任务 |
   |                          extensions                          | wiredtiger插件，如libwiredtiger_lz4.so位置，当使用lz4时可能需要指定 |
   |                    io_capacity=(total=0)                     |   控制每秒钟能够读写数据量的上限，若超过将休眠，0则不限制    |
   | log = (archive=true, compressor=lz4, enabled=true, file_max=100M, path=./logs, prealloc=true, recover=true, zero_fill=false) | 日志配置，包括自动归档不需要的日志，日志压缩方法，是否启用日志，单个日志文件大小，日志存储路径，是否预分配日志空间，是否在异常关闭等情况下进行数据恢复，想日志写0等内容 |
   |                           readonly                           |                             只读                             |
   |                          statistics                          |                    维护统计数据，影响性能                    |

2. 对session使用配置

   在connection中使用open_session打开并配置session：

   ```c
   conn->open_session(conn, NULL /* event handler */, NULL /* config str */, &session);
   ```

   session包含较少的[配置选项](http://source.wiredtiger.com/3.2.1/struct_w_t___c_o_n_n_e_c_t_i_o_n.html#adad5965cd4a60f65b5ac01f7ca6d1fc0)

   |       选项        |                           内容                           |
   | :---------------: | :------------------------------------------------------: |
   |   cache_cursors   |                 允许cursor重用，默认允许                 |
   | ignore_cache_size | 忽略缓存大小，若缓存已满不会阻塞当前会话的操作，默认禁止 |
   |     isolation     |                      会话隔离级别，                      |

3. 对cursor使用配置

   ```c
    session->open_cursor(session, "table:mytable" /* uri of table or index */, 
                         NULL /* cursor to dup */,
                         NULL /* config string */, &cursor);
   ```

   cursor类型：

   |                     uri                     |                       内容                       |
   | :-----------------------------------------: | :----------------------------------------------: |
   |      “table:table_name[(projection)]”       |       表，可对表中的部分数据进行投影并访问       |
   | “index:table_name:index_name[(projection)]” | 某个表对应的索引，可对表的部分数据进行投影并访问 |
   |     “colgroup:table_name:colgroup_name”     |           列组游标，可以对列组数据访问           |
   |       “join:table_name[(projection)]”       |                     join游标                     |

   [配置内容](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#afb5b4a69c2c5cafe411b2b04fdc1c75d)

   |    选项     |                             作用                             |
   | :---------: | :----------------------------------------------------------: |
   |    bulk     | 批量加载，但只适用于新创建的对象，必须顺序加载数据，默认false |
   | next_random | 调用cursor->next返回一个伪随机记录，默认false（不开启情况为key有序） |
   |  overwrite  | 可重写已有记录，默认true，此时可用insert覆写，若为false，则无法insert已有数据，只可调用update |
   |  readonly   |                          设置能查询                          |
   | statistics  |                   指定收集数据库统计信息，                   |

   

4. 对table或index使用配置

   于session上调用create创建table或index，创建对象的过程非事务性，无法保证ACID：

   ```c
   session->create(session, "table:mytable" /* name of table or index */,
                   "key_format=S,value_format=S" /* config string */);
   ```

   包含很多[配置选项](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a358ca4141d59c345f401c58501276bbb)，一些常用的如下：

   |       选项       |             作用             |
   | :--------------: | :--------------------------: |
   | block_compressor |           压缩引擎           |
   |    colgroups     | 列组，保存在一个单独的文件中 |
   |     columns      |         列的名称列表         |
   |    key_format    |     key的格式，字母表示      |
   |       type       |        lsm配置使用LSM        |
   |   value_format   |         value的格式          |

   此外还包括对B树内部节点、叶子节点、页大小，哈夫曼编码、前缀压缩、lsm相关的配置。

### 调优

1. 统计

   wiredtiger在运行过程中包含大量的统计数据，可以通过统计信息对数据库进行分析、调优。收集统计信息会降低性能应用。[link](http://source.wiredtiger.com/3.2.1/tune_statistics.html)

2. 压缩

   不同阶段可以配置不同的压缩算法。配置压缩可能会改变程序的吞吐量，若对于ssd等I/O速度快的系统，不使用压缩会降低cpu负载从而提高性能，而对于I/O速度慢的系统，配置压缩减小I/O体积可能会提高性能。

   - key-prefix

     每个page中相同的key前缀只保存一次从而减小对空间的需要。将为操作内存中的btree时带来cpu和内存的额外成本。

     通过 [WT_SESSION::create](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a358ca4141d59c345f401c58501276bbb) 在创建表或索引时开启前缀压缩。

     ```c
     "key_format=S,value_format=S,prefix_compression=true,prefix_compression_min=7"
     ```

   - directory

     每一页只保存相同值一次，通过 [WT_SESSION::create](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a358ca4141d59c345f401c58501276bbb) 在创建表或索引时指定字典最大值。

     ```c
     "key_format=S,value_format=S,dictionary=1000"
     ```

   - Huffman

     减小压缩单个key/value的体积，额外的cpu代价很高，应考虑是否启用。通过 [WT_SESSION::create](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a358ca4141d59c345f401c58501276bbb) 在创建表或索引时指定。

     ```c
     "key_format=S,value_format=S,huffman_key=english,huffman_value=english"
     ```

   - Block Compression

     通过块压缩，减小写入磁盘的数据体积。cpu的代价较高，需要考虑是否启用。若启用压缩，对于page size的配置将和实际磁盘的page size不再匹配。

     [WT_SESSION::create](http://source.wiredtiger.com/3.2.1/struct_w_t___s_e_s_s_i_o_n.html#a358ca4141d59c345f401c58501276bbb) 在创建表或索引时指定压缩引擎，包括snappy，lz4，zlib，zstd等，可能需要zdwiredtiger_open时指定压缩引擎插件位置，这取决于编译方式。

     ```
     "key_format=S,value_format=S,block_compressor=snappy"
     ```

3. bulk-load

   载入大量数据到一个新的数据对象时，使用批量载入会有更高的效率。[link](http://source.wiredtiger.com/3.2.1/tune_bulk_load.html)

4. cache

   理想情况下应为数据库配置足够的cache空间。可以使用wiredtiger_open配置cache_size，或调用[WT_CONNECTION::reconfigure](http://source.wiredtiger.com/3.2.1/struct_w_t___c_o_n_n_e_c_t_i_o_n.html#a579141678af06217b22869cbc604c6d4) 重新进行设置。

   可将对象配置为cache持久化数据，以避免数据被驱逐回收。

5. 页面驱逐

   当cache中数据占用接近最大的cache_size，进引发页面驱逐操作，可以使用wiredtiger_open配置或调用[WT_CONNECTION::reconfigure](http://source.wiredtiger.com/3.2.1/struct_w_t___c_o_n_n_e_c_t_i_o_n.html#a579141678af06217b22869cbc604c6d4) 重新进行设置对该驱逐操作进行配置。

   -  eviction_target （默认80%），维持cache的总体使用率，当超过将启动驱逐线程执行页面驱逐。
   - eviction_trigger（默认95%），若cache使用率达到该值，将启用应用级线程执行驱逐操作，此时将会有较高的延迟。
   - eviction_dirty_target（5%），eviction_dirty_trigger（20%），和上述二者类似，但用于dirty-page。
   - 可通过eviction来配置驱逐线程的数量，若缓存占用过高导致应用进程参与页面驱逐过程将导致很高的延迟。

6. I/O限制

   通过设置每秒读写数据量的上限来限制I/O带宽。当资源是共享的，如云或虚拟环境中会有帮助。当I/O溢出，引发溢出的线程将会休眠

   ```c
   wiredtiger_open(home, NULL, "create,io_capacity=(total=40MB)", &conn);
   ```

7. 持久化游标

   经常性打开新的游标是一个代价较大的操作，特别对于表和LSM树，对cursor进行缓存重用将可以提高性能。

8. 只读模式

   checkpoint的游标以只读模式打开，读取不占用wiredtiger的cache，而直接使用内存。使用只读模式将减小cache占用以及对cache管理工作的负载，以及从操作系统缓存到应用的内存拷贝。

9. 关闭连接

   关闭connection代价高，需要释放大量资源以及数据落盘等，若加快速度，可配置leak_memory=true。

10. **Linux transparent huge pages**

    linux系统中的**transparent huge pages**会影响wiredtiger的性能。一些linux系统开启了此功能。

    ```shell
    // disable it
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    ```

11. 其他详细见文档

### 测试

1. 测试总结

   - 使用sqlite3数据库时，晚高峰期间由于磁盘IO过高，模块基本停止工作，不能取得的数据，替换为wiredtiger后，工作正常。
   - 系统load在晚高峰期间明显降低。
   - 未开启压缩和开启压缩相比，cpu占用提高，但所在磁盘盘持续100%占用时间减少。

2. wiredtiger性能测试工具

   wiredtiger提供了wtperf工具用于性能测试。

### 问题

1. 联合索引无法按预期排序问题

   在实现disk-index模块中file_info表部分操作时，遇到使用部分多列联合索引时，某一列的整数类型不能按照预期顺序排序。后改用int64_t。原因不明。

2. 重启数据库后一段时间极高cpu占用和系统负载问题

   可能是由异常关闭导致扫描日志恢复数据导致。

3. 以不同配置打开相同数据库问题

   对于cache_size等配置，不影响重新打开，对于树类型、表结构等，必须相同。





