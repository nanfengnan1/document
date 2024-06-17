### C++封装

------

### 1. 封装抽象类

> c++中一个使用抽象来来做interface，给子类派生接口，抽象类无法创建ojbect
>
> 抽象类中一般只有构造函数和析构函数不是纯虚函数

#### 1.1 examples

```c++
// test.h
#ifndef __TEST_H__
#define __TEST_H__

#include <string>
#include <iostream>

namespace animal {

	class animal {
	public:
		animal();
		virtual ~animal();
		virtual void eat(std::string) = 0;
		virtual void sleep() = 0;

	protected:
		std::string name;
		int age;
	};

	class cat: public animal {
	public:
		cat(std::string, int, int);
		void eat(std::string);
		void sleep();	

	private:
		int type;
	};

}
#endif
```

```c++
// test.cc
#include "test.h"
#include <iostream>

namespace animal {

animal::animal()
{
	std::cout << "init animal" << std::endl;
}

animal::~animal()
{
	std::cout << "oh~" << std::endl;
}

cat::cat(std::string name, int age, int type)
{
	this->name = name;
	this->age = age;
	this->type = type;
}

void cat::eat(std::string things)
{
	std::cout << "cat eat " << things << std::endl;
}

void cat::sleep()
{
	std::cout << "cat cat likes to sleep" << std::endl;
}
	
}
```

```c++
// 测试类main.cc
#include "test/test.h"

using animal::cat;
using animal::animal;

int main(int argc, char *argv[])
{
	cat *ani = new cat("lili", 3, 1);
	ani->eat("fish");
	ani->sleep();

	delete ani;
	return 0;
}
```

执行g++ test.cc main.cc -o main   

![image-20240617201406747](./image/image-20240617201406747.png)