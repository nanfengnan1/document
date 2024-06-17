## C++输入输出流

### 1.c++的IO流框图 

> ios是一个抽象基类 -- 负责I/O的高层操作

![1659315639316](./image/IO框图.png)

### 2.c++流的定义

>  C++流是指信息从外部输入设备（如键盘）向计算机内部（如内存）输入和从内存向外部输出设备（显示器）输出的过程。这种输入输出的过程被形象的比喻为“流”。 
>
>  ```c++
>  c++中的类称为流类,用流类定义的对象称为流对象
>  ```
>
>  流是什么?
>
>  ```c++
>  流就是缓冲区的数据,用特定类型的指针指向每一个数据。
>  ```
>
>  流中读出和写入的底层原理?
>
>  ```c++
>  每个流都维护一个指针,读出和写入其实是借助于这个指针的移动实现的
>  ```
>
>  拓展：
>
>  ```c++
>  // 格式化I/O的头文件
>  #include<iomanip>
>  ```

### 3.c++的I/O对c的发展

> 1.类型安全:c++的输入流和输出流(编译系统)对类型进行严格检查  
>
> ```c++
> eg:printf不进行类型检查,printf("%d","C++");
> // 这个输出时字符串的地址,要是使用c++的输入输出流的话,类型不符合编译就无法通过
> ```
>
> 2.可拓展性:可以重载运算符等操作

### 4.`#include<iostream>`头文件

> `iostream包含四个全局对象`
>
> ```c++
> // iostream中的源代码 -- 在程序开始时就自动创键四个对象,把流对象和对应设备绑定
> extern istream cin;		/// Linked to standard input  --  对应设备:键盘
> extern ostream cout;		/// Linked to standard output  -- 对应设备:屏幕
> extern ostream cerr;		/// Linked to standard error (unbuffered) -- 对应设备:屏幕
> extern ostream clog;		/// Linked to standard error (buffered)  -- 对应设备:屏幕
> ```
>
> #### cin对象详解  -- 是istream_withassign的对象
>
> ```c++
> 用cin和">>"提取运算符向显示器(屏幕-标准输出设备)输出数据流程:
> 1.先从键盘(标准输入设备)读取数据到键盘输入缓冲区中
> 2.当遇到换行,会将键盘输入缓冲区中的数据提取到cin输入流中(<<的作用)
> ```
>
> ```
> "<<":被重载为插入运算符
> ">>":被重载为提取运算符
> ```
>
> ```c++
> cout == console output
> cerr == console error  -- cerr的输出可以输出到显示器,也可以重定向到文件中  -- 不经过缓冲区
> clog == console log    -- clog的输出经过缓冲区(满或endl输出)-- 这个是和cerr的区别    
> ```
>
> #### cout对象详解  -- 是ostream_withassign的对象
>
> ```c++
> cout流在内存中开辟一个输出缓冲区:
> 1.当像缓冲区写入数据,满了或者遇到endl时,将缓冲区数据提取到cout输出流上。
> 遇到endl,不管缓冲区是否满了,都将数据插入到cout流中+一个换行,同时清空缓冲区。
> ```
>
> 注意:
>
> ```c++
> char *n = "fenglei";
> cout输出指针所执行的内容:cout<<n;//fenglei
> ```
>
> 

### 4.标准I/O流

#### 4.1 标准输出流 cout,cerr,clog

> `标准输出流就是流向标准输出设备(显示器)的数据`

##### 4.1.1 标准类型数据的格式输出

> 1.两种输入输出格式
>
> 1. 无格式输入输出
> 2. 有格式输入输出
>
> 1.1 无格式输入输出 -- 略
>
> 1.2 有格式输入输出
>
> ```c++
> 1.使用控制符控制格式输出  -- 需要导入#include<iomanip>头文件
> 2.使用流对象的相关成员函数
> ```
>
> 1. 格式控制符  -- 导入头文件 `#include<iomanip>`
>
>    | 控制符                       | 作用                                                         |
>    | ---------------------------- | ------------------------------------------------------------ |
>    | dec                          | 设置整数的基数为10                                           |
>    | hex                          | 设置整数的基数为16                                           |
>    | oct                          | 设置整数的基数为8                                            |
>    | setbase(n)                   | 设置整数的基数为n(n只能为8,10,16三者之一)                    |
>    | setfill(c)                   | 设置填充字符c,c可以是字符常量或字符变量                      |
>    | setprecision(n)              | 设置实数的精度为n位。在以十进制小数形式输出时n代表有效数字。在以fixed(固定小数位数)形式和scientific(指数)形式输出时n为小数位数 |
>    | setw(n)                      | 设置字段位宽为n位,右对齐                                     |
>    | setiosflags(ios::fixed)      | 设置浮点数以固定的小数位显示                                 |
>    | setiosflags(ios::scientific) | 设置浮点数以科学计数法显示(指数形式)                         |
>    | setiosflags(ios::left)       | 输出数据左对齐                                               |
>    | setiosflags(ios::right)      | 输出数据右对齐                                               |
>    | setiosflags(ios::skipws)     | 忽略前导的空格                                               |
>    | setiosflags(ios::uppercase)  | 在以科学计数法输出E和以16进制输出字母X时,以大写表示          |
>    | setiosflags(ios::showpos)    | 输出正数时给出"+"号                                          |
>    | resetioflags()               | 终止已设置的输出格式状态,在括号中应指定内容                  |
>
> 2. 流对象的成员函数
>
> 2.用流成员函数put输出**一个**字符 -- 本质输入看的时ASCII
>
> ```c++
> 参数:字符 or 字符的ASCII or 整数表达式
> cout.put('a');     // a
> cout.put('0x30'); // 0
> cout.put(1+48);  // 1
> ```
>
> 

#### 4.2 标准输入流 cin

> ```c++
> cin是istream派生类的对,他从标准输入设备(键盘)获取数据，**程序中的变量通过流提取运算符">>"从流中提取数据**。流提取运算符">>"从流中提取数据时通常跳过输入流中的空格、tab键、换行符等空白字符。
> ```
>
> 1.特殊用法：可以通过判断输入流对象的状态来判断输入是否成功  -- 可用于连续输入  【重点】
>
> ```c++
> cin == 0;// 输入流正常状态
> cin != 0;// 输入流出错状态
> int a;
> while(cin>>a); // 连续输入a,直到输入非int类型或者输入文件结束符^z(ctrl+z),cin流处于出错状态,退出循环
> ```
>
> 2.字符输入的流成员函数get -- 读入一个字符   -- 对应C的getchar  【有问题,第三个函数不好使,指针时候不好使】  -- get读到终止字符后,指针停在终止字符处,不修改下次无法输入
>
> ```c++
> 1.不带参数:返回值是读入的字符;遇到EOF返回-1
> cin.get();  -- 没遇到EOF可以一个一个自动读取输入流中的数据
> 2.带一个参数:从输入流中读取一个字符到ch中。成功,返回!0;否则返回0;
> cin.get(ch);
> 3.有3个参数:从输入流中读取n-1个字符,赋给指定的字符数组(或字符指针指向的数组),如果在读取n-1个字符之前遇到指定的终止字符,则提前结束读取。成功,返回!0;否则返回0;
> cin.get(字符数组/字符指针,字符个数n,终止字符); 
> // 终止字符可以使用'^z'
> ```
>
> 3.字符输入流的成员函数getline --- 读一行数据,读完数据后指向**终止字符的下一个位置**
>
> ```c++
> cin.getline(字符数组/字符指针,字符个数n,终止字符);
> // getline可以读取除了终止字符以外的一切字符,但也仅仅只能读取字符
> ```
>
> 4.peek()函数  -- cin.peek()
>
> `预测下一个字符,但是返回值是指向当前字符`
>
> 5.putback函数 -- cin.putback()
>
> `将前面用get或getline函数从输入流中读取的字符ch返回到输入流,插入到当前指针位置,以供后面读取`
>
> 6.ignore函数 
>
> `跳过输入流中n个字符,或者遇到指定的终止字符(默认是EOF)提前结束`
>
> ```c++
> cin.ignore();// 跳过输入流中的一个字符,指针后移一次
> cin.ignore(n,ch); // 跳过输入流中的n个字符,指针后移n个单位
> // 一般搭配cin.get使用,因为cin.get读完之后,指针停在终止字符处,指针不后移动,下一次输入读取不了,这时候使用cin.ignore(),可以把指针移动到终止字符后面,就可以读取后面输入流中的字符了
> ```
>
> 

### 5.文件流

> 文件的读取和写入都是移动流中的指针实现的。
>
> 文件流是以外存文件为输入输出对象的数据流

#### 5.1 文件分类 -- 根据文件中的数据的组织格式

> 1.ASCII文件(字符文件或文本文件)
>
> ```c++
> 文件中每一个字节放一个ASCII代码,代表一个字符。
> ```
>
> 2.二进制文件(字节文件)
>
> ```c++
> 如果把内存中的数据按其在内存中的存储形式原样输出到磁盘上存放,就是二进制文件。
> ```

#### 5.2 高级I/O和低级I/O

> 高级I/O
>
> ```c++
> 把若干个字节组合为一个有意义的单位,然后以ASCII字符形式输入和输出。
> ```
>
> 低级I/O   --- 快,大容量
>
> ```c++
> 以字节为单位直接输入输出。
> ```

#### 5.3 文件流

> ```c++
> 每一个文件流都有一个内存缓冲区和其对应。
> ```
>
> 输出文件流
>
> ```c++
> 从内存流向外存文件的数据。
> ```
>
> 输入文件流
>
> ```c++
> 从外存文件流向内存的数据。
> ```

#### 5.4 文件操作的文件类

> ifstream
>
> ```c++
> 支持从磁盘文件的输入。
> ```
>
> ostream
>
> ```c++
> 支持向磁盘文件的输出。
> ```
>
> fstream
>
> ```c++
> 支持对磁盘文件的输入输出。 
> ```

#### 5.5 文件的打开

> 1.打开文件是指在文件读写之前做必要的准备:
>
> ```c++
> 1.为文件流对象和指定的磁盘文件建立关联,以便使文件流流向指定的磁盘文件
> 2.指定文件的工作方式
>     
> -- 两种实现    
> -- 1.调用文件流的成员函数open
> -- 2.在定义文件流对象时指定参数    
> ```
>
> 2.调用文件流的成员函数open
>
> ```c++
> ofstream f;
> f.open("文件路径/文件名",文件打开方式);
> ```
>
> 3.在定义文件流对象时指定参数  
>
> ```c++
> ofstream f("文件路径/文件名",文件打开方式);
> ```
>
> 4.输入输出方式(文件的工作方式)   --- 在ios中定义的
>
>  ![img](./image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQxODc5MzQz,size_16,color_FFFFFF,t_70-1718626686511-3-1718626712762-6.png)
>
> ```c++
> 1.可以使用"|"的方式组合文件打开方式
> 2.每一个打开的文件都有一个文件指针,该文件指针的初始位置有I/O方式指定,每次文件的读写都从文件指针当前位置开始。每读入一个字节,指针就后移一个字节。当文件指针移动到最后,就会遇到文件结束符(占一个字节,值为-1)
> ,此时流对象的成员函数eof的值为非0,就表示文件结束了。    
> ```
>
> 5.判断文件是否打开
>
> ```c++
> 文件流对象的成员函数:is_open()函数;return 0,打开失败;return !0,打开成功
> fstream f("a.txt",ios::in);
> if(f.is_open())
>     cout<<"打开成功";
> ```
>

#### 5.6 文件状态判断

> 1.文件打开是否失败(或格式错误)
>
> ```c++
> 文件流对象.fail()/is_open();return true,失败;否则return false;
> ```
>
> 2.判断文件是否到达末尾
>
> ```c++
> 文件流对象.eof();return true,文件到达末尾;否则return false;这个函数只是判断,不改变指针移动
> // usage:out是文件输入流对象
> while(!out.eof()) // 当文件输入流读取未结束
>     把数据读取到字符指针/字符数组中;
> ```
>
> 3.判断文件在读写过程中是否出错
>
> ```c++
> 文件流对象.bad();return true,文件读写错误;否则return false;
> ```
>
> 4.以上三个函数的集合  -- 最通用的
>
> ```c++
> 文件流对象.good();如果没有以上任何一个函数的状况返回true;否则,此函数返回false;
> ```
>
> 5.重置文件的状态标记
>
> ```c++
> 文件流对象.clear();
> ```

#### 5.6 获得和设置流指针

> 1.所有输入输出流对象都有至少一个流指针:
>
> `ifstream,类似于istream,都有一个get pointer,指向下一个将被读取的元素`
>
> `ofstream,类似于ostream,都有一个put pointer,指向写入下一个元素的位置`
>
> `fstream,类似于iostream,同时继承get 和 put pointer`
>
> 2.得到当前输入输出流指针位置 -- tellg()和tellp()
>
> ```c++
> tellg()和tellp();-1表示文件结尾
> // 这两个成员函数不用传入参数,返回pos_type类型的值(根据ANSI-C++标准),就是一个整数,代表当前get流指针的位置(tellg函数)或代表当前put流指针的位置(tellp)
> ```
>
> 3.设置流指针的位置seekg(pos_type position)和seekp(pos_type position)  -- 绝对位置 -- 文本文件建议使用
>
> ```c++
> pos_type seekg(pos_type position); // 设置输入流的指针位置为position
> pos_type seekp(pos_type position); // 设置输出流的指针位置为position
> ```
>
> 4.设置流指针的位置seekg(off_type offset,seekdir direction)和seekp(off_type offset,seekdir direction)  -- 可以指定由参数direction决定的具体指针开始计算的一个位移
>
> | direction的参数 | 含义                           |
> | :-------------- | :----------------------------- |
> | ios::beg        | 从流开始位置计算的位移         |
> | ios::cur        | 从流指针当前位置开始计算的位移 |
> | ios::end        | 从流末尾处开始计算的位移       |
>
> ```c++
> 例子：
> file.seekg(0,ios::beg); //让文件指针定位到文件开头
> file.seekg(0,ios::end); //让文件指针定位到文件末尾
> file.seekg(10,ios::cur); //让文件指针从当前位置向文件末方向移动10个字节
> file.seekg(-10,ios::cur); //让文件指针从当前位置向文件开始方向移动10个字节
> file.seekg(10,ios::beg); //让文件指针定位到离文件开头10个字节的位置
> ```
>
> ```c++
> 注意:
> 流指针 get 和 put 的值对文本文件(text file)和二进制文件(binary file)的计算方法都是不同的，因为文本模式的文件中某些特殊字符可能被修改。由于这个原因，建议对以文本文件模式打开的文件总是使用seekg 和 seekp的第一种原型，而且不要对tellg 或 tellp 的返回值进行修改。对二进制文件，你可以任意使用这些函数，应该不会有任何意外的行为产生。
> ```

#### 5.7 文件的关闭

> ```c++
> 文件流对象.close()
> // 关闭文件其实是解除了该磁盘文件和文件流的关联,这样就不能通过文件流操作文件了,实现了关闭文件。    
> ```

### 6 字符文件的操作

#### 6.1 字符文件的读取

> 1.从输入流按行读取 
>
> ```c++
> istream& getline ( char* is , int t , char delim );
> // is:把读出来的字符扔到is字符数组/字符指针中
> // t:是一行读取的字符个数,这个参数可以省略
> // delim:遇到delim该行读取结束,默认是'\n'
> // 带t用法就是当一行读取t个或遇到'\n'时本行读取结束
> ```
>
> 2.把输入流中的数据放到指定的容器中
>
> ```c++
> // cin>>容器;容器类型任意
> ifstream in(”file",ios:in);
> char c;
> string str;    
> while(!in.eof()){  // 输入流未结束          
> 	in>>c; // 从输入流中读取一个字符放到c中,同时输入流中指针移动一个位置 
>     int>>str; // 把输入流中'\t',空白符，换行符分隔的数据都放到str中
>     cout<<c;
> }
> ```
>
> 3.把字符读入到指定的字符数组/字符指针中
>
> ```c++
> // 读取t个元素到字符指针p中
> in.read(char* p,int t);
> // 读取t个元素到字符数组中
> char p[100];int t;
> in.read(p,t);
> ```
>
> 4.使用运算符从文件流中读出数据
>
> ```c++
> 输入流对象>>字符串/字符数组;
> // 将数据从到输入流中读到字符串/字符数组中
> // 遇到,换行,空格,Tab键,一个数据读取结束,放到字符数组/字符串中
> ```

#### 6.2 字符文件的写入

> 1.使用运算符向文件中写入数据
>
> ```c++
> out<<数据; // 将数据插入到输出流中
> ```
>
> 2.放一个字符到文件输出流中
>
> ```c++
> out.put(char c);
> ```

### 7. 二进制文件的操作

#### 7.1 二进制文件的打开方式

> 1.以二进制方式读取文件
>
> ```c++
> ios::in | ios::binary
> ```
>
> 2.以二进制方式写入文件
>
> ```c++
> ios::out | ios::binary
> ```

#### 7.2 二进制文件的读操作

> ```c++
> istream& read(char* buffer,int len);
> // 读取输入流上len个字节到buffer的存储空间
> ```
>
> 2.使用运算符从文件中读出数据
>
> ```c++
> 输入流对象>>字符串对象/字符数组; 
> // 将数据从到输入流中读到字符串/字符数组中
> // 遇到,换行,空格,Tab键,一个数据读取结束,放到字符数组/字符串中
> ```

#### 7.3 二进制文件的写操作

> 1.使用函数向文件中写入数据
>
> ```c++
> ostream& write(const char* buffer,int lent);
> // 把buffer中的长度为lent的数据写入到输出文件流中
> ```
>
> 2.使用运算符向文件中写入数据
>
> ```c++
> 输出文件流对象<<数据;
> // 将数据插入到输出流中
> ```

### 6.字符串流

> 头文件:
>
> ```c++
> #include<sstream>
> ```

> 字符串流也称内存流,以内存中用户定义的字符数组(字符串)为输入输出对象。
>
> `istringstream:从内存中的字符缓冲区读取数据`
>
> `ostringstream:写数据到内存中的字符缓冲区`
>
> `iostringstream:支持对内存中字符缓冲区的输入和输出操作`

#### 6.1 应用1:用于类型转换

#### 6.2 应用2:用于空格分隔字符串的切割  -- 利用的是输入流对象遇见空格,tab,换行为一次输入读入或写出

> ```c++
> stringstream ss("Let's go to execute this program!");
>     string s;
>     while (ss>>s){
>         cout<<s<<endl;
>     }
> ```

### 7.文件流例子

```c++
class student{
public:
    student(const string name,const int age,const char sex):name(name),age(age),sex(sex){}
    void display(){
        cout<<name<<" "<<age<<" "<<sex<<endl;
    }
    bool ready_to_read_write(const char* __s,ios_base::openmode write_mode,ios_base::openmode read_mode){
        __s = __s;
        mode = mode;
        out.open(__s,write_mode);
        in.open(__s,read_mode);
        return out.is_open() && in.is_open()?true:false;
    }
    void write_to_file(const student &s){
        stringstream ss;
        ss<<s.age;ss>>x1;
        x1 = s.name+"\t"+x1+"\t"+s.sex+"\n";
        const char* n = x1.c_str();
        // 将n写入输出流
        out<<n;
    }
    void read_from_file_to_display(){
        char n[size];
        while (!in.eof()){
            // 从输入流得到一行size个字符
//            in.getline(n,size);
            in>>n;
            cout<<n<<endl;
        }
    }
    virtual ~student(){
        if (in.is_open())
            in.close();
        if (out.is_open())
            out.close();
    }
private:
    string name;
    int age;
    char sex;
    char* __s;
    ios_base::openmode mode;
    ofstream out;
    ifstream in;
    const int size = 10;
    string x1;
};
```

