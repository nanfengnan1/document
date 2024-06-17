## C++多态性(ploymorphism)和虚函数

[TOC]



### 1.多态性

> 1.什么是多态性?
>
> ```
> 1.多态就是事物的多种状态,在不同角度看有不同的功能。
> 2.在C++中,多态性的表现形式之一是:具有不同功能的函数可以用同一个函数名,这样就可以实现用一个函数名调用不同的内容的函数。
> 3.多态性是"一个接口,多种实现方法".
> 
> 简言之:
> 对同一消息(同名函数),不同对象有不同的响应方式
> ```

### 2. 多态性分类(按系统实现)

#### 2.1 静态多态性 

> 静态多态是编译时候编译器可以确定具体的调用函数，也叫编译时多态
>
> c++中函数重载，运算符重载都属于编译时多态的具体应用
>
> c++实现编译时多态的主要方法是函数重载

编译时多态特点

> 静态多态性的函数调用速度快、效率高,  但缺乏灵活性
>静态多态性必须在编译的时候就知道要调用的函数和方法, 否则报错

#### 2.2 动态多态性

> 编译时无法确定最终要调用的函数，而是在程序运行过程中才能动态的确定操作所针对的对象极其调用的函数，也叫运行时多态
>
> 换句话说，可以不同具有继承关系的对象调用同一函数，表现不同结果
>
> c++中使用````虚函数````实现运行时多态

#### 2.3 静态多态性实例

```c++
class Point{
public:
    Point(double x,double y):x(x),y(y){}
    friend ostream& operator<<(ostream &out, const Point &p);
    double getX() const {
        return x;
    }
    double getY() const {
        return y;
    }
    void setPoint(int x,int y){
        this->x = x;
        this->y = y;
    }
protected:
    double x;
    double y;
};

ostream& operator<<(ostream& out,const Point &p){
    out<<"("<<p.x<<","<<p.y<<")"<<endl;
}

class Circle:virtual public Point{
public:
    Circle(double x,double y,double r):Point(x,y),r(r){}
    void setRadius(double r){
        this->r = r;
    }
    double getRadius() const {
        return r;
    }
    double getArea() const {
        return 3.14*r*r;
    }
    friend ostream& operator<<(ostream& out,const Circle &c);

protected:
    double r;
};

ostream& operator<<(ostream& out,const Circle &c){
    out<<"center:"<<"("<<c.x<<","<<c.y<<")"<<" ";
    out<<"r:"<<c.r<<" "<<"area:"<<c.getArea()<<endl;
}

class Cylinder: public Circle{
public:
    Cylinder(double x,double y,double r,double h):Point(x,y),Circle(x,y,r),h(h){}
    void setHeight(double h){
        h = h;
    }
    double getHeight() const {
        return h;
    }
    double area() const {
        return 2*3.14*r*r+2*3.14*r*h;
    }
    double volume() const{
        return 3.14*r*r*h;
    };
    friend ostream& operator<<(ostream& out,const Cylinder &c);
private:
    double h;
};

ostream& operator<<(ostream& out,const Cylinder &c){
    out<<"i am cyliner"<<endl;
}
```

### 3. 虚函数 

> 解决动态多态问题，虚函数details较多，以后细聊

#### 3.1 什么虚函数

> 所谓虚函数就是在基类声明 函数是虚拟的，并不是实际存在的函数，**然后再派生类中才正式定义此函数**。在程序运行期间，用指针指向某一派生类对象，这样就能调用指针指向的派生类对象中的函数。

#### 3.2 虚函数的作用

> 虚函数的作用就是允许在派生类中重新定义和基类同名的函数，并且可以通过基类指针或引用来访问基类和派生类中的同名函数。

#### 3.3 虚函数解决的问题

> 1.问题  --- 本质是由基类和子类之间的自动赋值转换产生的
>
> 虚函数解决的主要问题就是,基类指针(基类引用)指向子类的对象时，**调用子类中和基类同名的方法时**，只能调用到基类中所独有的成员，无法调用到子类特有的数据。
>
> 2.分析：
>
> 这样做并没有实现一名多用，没有实现多态。因为父类引用子类对象时，只能访问基类的同名函数，无法调用子类的同名函数
>
> 3.看代码
>
> ```c++
> class Point{
> public:
>  Point(double x,double y):x(x),y(y){}
>  void display(){
>      cout<<x<<" "<<y<<endl;
>  }
> protected:
>  double x;
>  double y;
> };
> 
> class Circle:virtual public Point{
> public:
>  Circle(double x,double y,double r):Point(x,y),r(r){}
>  void display(){
>      cout<<x<<" "<<y<<" "<<r<<endl;
>  }
> protected:
>  double r;
> };
> 
> int main(int argv,char** argc) {
>  Point t(2,1);
>  Point* p;
>  p = &t;
>  p->display();
>  Circle c(12,1,3);
>  p = &c;
>  p->display();
>  return 0;
> }
> // 输出结果
> //2 1
> //12 1
> // 这两次display都是调用基类的disply函数,没有调用子类的display函数,无法实现多态。
> 因为,把子类对象给父类指针进行了自动转换,先将派生类的对象指针变为基类的指针,这样基类指针指向的是派生对象中的基类部分,无法访问到子类的特有部分,永远访问的父类的同名函数,无法实现多态。 -- 父类和子类的自动类型转换导致无法实现多态
> ```
>
> 4.总结
>
> 我们虚函数就是为了帮助基类和子类同名函数,在不同调用时可以实现不同的功能,实现动态多态性。父类引用子类对象时,可以调用子类的同名函数,不再去调用父类的同名函数

#### 3.4 虚函数的声明

> 在基类和派生类同名的函数前面加一个virtual关键字。 -- 只在基类中加virtual
>
> 1.上边的例子改进
>
> ```c++
> #include <iostream>
> 
> #define ENABLE_RUNNING_PLOYMORPHISM
> class point {
> public:
> 	point(int, int);
> // #ifdef ENABLE_RUNNING_PLOYMORPHISM	
> 	virtual void display();
> #else
> 	void display();
> #endif
> 
> protected:
> 	double x, y;
> };
> 
> class circle:virtual public point {
> public:
> 	circle(int, int, int);
> 	void display();	
> 	
> protected:
> 	double r;
> };
> 
> point::point(int x, int y):x(x), y(y)
> {
> 	std::cout << "init point (" << this->x << ", " << this->y << ")" << std::endl;
> }
> 
> void point::display()
> {
> 	std::cout << "display (" << this->x << ", " << this->y << ")" << std::endl;
> }
> 
> circle::circle(int x, int y, int r):point(x, y), r(r)
> {
> 	std::cout << "init circle (" << this->x << ", " << this->y << ", " << this->r << ")" << std::endl;
> }
> 
> void circle::display()
> {	
> 	std::cout << "display (" << this->x << ", " << this->y << ", " << this->r << ")" << std::endl;
> }
> 
> int main(int argv,char** argc) {
>  Point t(2,1);
>  Point* p;
>  p = &t;
>  p->display();
>  Circle c(12,1,3);
>  p = &c;
>  p->display();
>  return 0;
> }
> // 输出结果
> //2 1
> //12 1 3
> ```
>
> ```c++
> 现在用同一指针变量(指向基类的指针),不但可以调用基类的display函数,也可以调用子类的display函数。而且调用形式都是一样的p->display(),用一个基类指针可以调用不同派生类中和基类同名的虚函数。
>     
> 我们这里使用ENABLE_RUNNING_PLOYMORPHISM来决定是否开启运行时多态    
> ```

#### 3.5 虚函数的使用

> ```c++
> // 使用流程
> 1.在基类中用virtual声明函数为虚函数,在类外定义虚函数时,不加virtual    -- 基类中定义虚函数
> 2.在派生类中重新定义用virtual修饰的虚函数的函数体,注意参数列表不能修改。  --- 派生类中重写虚函数
> 3.定义一个指向基类的指针,并使它指向同一基类下面的某一个派生类的对象。   --- 父类引用子类对象
> 4.通过该指针变量调用此虚函数,此时调用的虚函数就是指针变量所指向的对象的同名函数。 -- 调用指向对象的虚函数，根据指向不同的对象调用不同功能的同名虚函数
> ```
>
> ```c++
> 注意:
> 如果派生类中没有对基类的虚函数重新定义,则派生类简单地继承其直接基类的虚函数。
> ```
>
> ```c++
> 虚函数实现多态性的条件
> 1.继承
> 2.派生类重写同名虚函数
> 3.父类指针引用子类对象
> -- 这里使用指针不使用引用,是因为引用只能指向一个派生类对象(初始化时),而指针可以指向多个派生类对象。   
> ```

#### 3.6 虚函数的维护

> 使用虚函数需要消耗一定内存。编译系统会为一个带有虚函数的类构造一个虚函数表,他是一个指针数组，存放每个虚函数的入口地址。可以减少指针进行动态关联虚函数的时间。

### 4. 虚析构函数

#### 4.1 解决的问题

> 当定义指向基类的指针时,在new一个建立一个临时对象后,如果要释放对象时,只会执行基类的析构函数，不会执行派生类的构造函数
>
> eg:
>
> ```c++
> class Point{
> public:
>  ~Point(){
>      std::cout<<"Point destructor"<<endl;
>  }
> };
> 
> class Circle:public Point{
> public:
>  ~Circle(){
>      cout<<"Circe destructor"<<endl;
>  }
> };
> 
> int main(int argv,char** argc) {
>  Point* p = new Circle;
>  delete p;
>  return 0;
> }
> // 输出结果:
> // Point destructor
> // 不会执行派生类的析构函数
> ```

#### 4.2 虚析构函数 

> 解决delete基类指针,不执行派生类析构函数的问题

> 将基类的构造函数声明为virtual
>
> ```c++
> virtual ~类名(){}
> ```

### 5.技巧

> 1.析构函数都声明为virtual。
>
> 2.同名函数中基类的同名函数声明为virtual

### 6. 纯虚函数

> 类似于抽象函数

#### 6.1 解决问题

> ```c++
> 有时在基类中将某一成员函数定义为虚函数,并不是基类本身的要求(基类不使用), 而是考虑到派生类的需要, 在基类中预留了一个函数名, 具体功能留给派生类根据需要去定义。   这样的虚函数应定义为纯虚函数
> ```

#### 6.2 纯虚函数声明

> ```c++
> class 类名{
> virtual 函数类型 函数名(参数列表) = 0;
> };
> ```
>
> ```
> 纯虚函数就是在声明虚函数时被“初始化”为0的函数。
> ```
>
> ```c++
> 注意:
> 1.纯虚函数没有函数体
> 2.最后面的"=0"并不表示函数返回值为0,他只起形式上的作用,告诉编译系统"这是纯虚函数"
> 3.这是一个声明语句,";"结尾
> 4.纯虚函数不定义无法调用
> ```

#### 6.3 纯虚函数和虚函数区别

> 1. 定义方式不同
>
>    ```c++
>    虚函数定义只需要在类的函数前面添加virtual关键字
>    纯虚函数既要添加virtual关键字还要在函数末尾添加 = 0;
>    ```
>
> 2. 作用不同
>
>    ```c++
>    虚函数是为了实现有亲缘关系的对象之间的运行时多态
>    纯虚函数是基类不可以实现的，定义纯虚函数是为了实现一个接口，起到一个规范的作用，规范继承这个类的程序员必须实现这个函数
>    ```

### 7. 抽象类

> 作为基本数据类型或者用来建立派生类，充当面向对象语言中的interface

> ```c++
>这种不用来定义对象而只作为一种基本数据类型用作继承的类,称为抽象类。由于它常做基类, 通常称为抽象基类。
> ``凡是包含纯虚函数的类都是抽象类``。因为纯虚函数不能被调用, 包含纯虚函数的类是无法建立对象的。
>```
> 
> 组成
> 
> 类中都是纯虚函数组成的
>
> 无法实例化