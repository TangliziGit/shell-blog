题目链接：<https://cn.vjudge.net/problem/POJ-1001>

以前写过一个高精度乘法，但是没有小数点，实现起来也没什么难得，
现在把代码都般过来，等会把旧电脑弄一弄，暂时就不写题解了

### 代码
```cpp
#include <cstdio>
#include <cstring>
struct BigInteger{
	int dot, size;
	char num[600];
	BigInteger(int size=0, int dot=0):size(size),dot(dot) {
		for (int i=0; i<600; i++) num[i]=0;
	}
	BigInteger(const char str[]):size(0),dot(0) {
		for (int i=0; i<600; i++) num[i]=0;
		int len=strlen(str);
		for (int i=len-1; i>=0; i--)
			if (str[i]=='0') len--;
			else break;
		for (int i=len-1; i>=0; i--){
			if (str[i]=='.') dot=len-i-1;
			else num[size++]=str[i]-'0';
		}
	}

	BigInteger operator * (const BigInteger &a) const{
		BigInteger ans(size+a.size, dot+a.dot);
		for (int i=0; i<size; i++){
			for (int j=0; j<a.size; j++){
				int tmp=num[i]*a.num[j], low=(tmp+ans.num[i+j])%10,
					high=(tmp+ans.num[i+j])/10+ans.num[i+j+1];
				ans.num[i+j]=low;
				ans.num[i+j+1]=high;
			}
		}
		while (ans.num[ans.size-1]==0) ans.size--;
		return ans;
	}
	BigInteger operator ^ (const int n) const{
		BigInteger ans("1"), tmp;
		memcpy(&tmp, this, sizeof(*this));
		for (int i=1; ; ){
			if (n&i) ans=ans*tmp;
			if ((i<<=1)<=n) tmp=tmp*tmp;
			else break;
		}
		return ans;
	}
	void show(void){
		if (dot>size-1){
			printf(".");
			for (int i=0; i<dot-size; i++) printf("0");
			dot=0;
		}
		for (int i=size-1; i>=0; i--){
			printf("%d", num[i]);
			if (dot && i==dot) printf(".");
		}printf("\n");
	}
};

int main(void){
	char inpt[600]; int n;
	while (scanf("%s%d", inpt, &n)==2){
		BigInteger a(inpt);
		(a^n).show();
	}

	return 0;
}
```


Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|352kB|1436|G++|2018-01-20 15:27:27