#ifndef STRING_H
#define STRING_H

#include <cstring>
#include "vector.h"
#include "aux_hash_table.h"

namespace april_utils {

  class string {
  public:
    typedef char value_type;
    typedef vector<char> container;
    typedef char& reference;
    typedef const char& const_reference;
    typedef container::iterator        iterator;
    typedef container::const_iterator  const_iterator;
    typedef container::difference_type difference_type;
    typedef container::size_type       size_type;
  private:
    vector<char> vec;
    
  public:
    string();
    string(const char *ptr);
    string(const char *ptr, size_t len);
    string(const string& other);
    ~string();
    string &operator=(const string &other);
    string &operator+=(const string &other);
    void append(const string &other);
    bool operator==(const string &other) const;
    bool operator<(const string &other)  const;
    bool operator<=(const string &other) const;
    char &operator[](unsigned int i);
    char  operator[](unsigned int i) const;
    void push_back(char c);
    void pop_back();
    const char *c_str() const;
    const char *data() const;
    char *begin();
    char *end();
    const char *begin() const;
    const char *end() const;
    size_type size() const;
    size_type max_size() const;
    void resize(size_type size);
    size_type capacity();
    void reserve(size_type size);
    void clear();
    bool empty();
    void swap(string &other);
    char  at(unsigned int i) const;
    char &at(unsigned int i);
    char  front() const;
    char &front();
    char  back() const;
    char &back();
  };
  
  // For hash tables
  template <> struct default_hash_function<string> {
    static const unsigned int cte_hash  = 2654435769U; // hash Fibonacci
    long int operator()(const string &s1) const {
      unsigned int resul = 1;
      for (const char *r = s1.begin(); r != s1.end(); r++)
        resul = (resul+(unsigned int)(*r))*cte_hash;
      return resul;
    }
  };
  
}

#endif // STRING_H
