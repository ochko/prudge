class CppVersionUp < ActiveRecord::Migration
  CSTRING = '(memcpy|memmove|strcpy|strncpy|strcat|strncat|memcmp|strcmp|strcoll|strncmp|strxfrm|memchr|strchr|strcspn|strpbrk|strrchr|strspn|strstr|strtok|memset|strerror|strlen)'

  CSTDIO = '(remove|rename|tmpfile|tmpnam|fclose|fflush|fopen|freopen|setbuf|setvbuf|fprintf|fscanf|printf|scanf|sprintf|sscanf|vfprintf|vprintf|vsprintf|fgetc|fgets|fputc|fputs|getc|getchar|gets|putc|putchar|puts|ungetc|fread|fwrite|fgetpos|fseek|fsetpos|ftell|rewind|clearerr|feof|ferror|perror|EOF|FILENAME_MA|NULL|TMP_MAX|FILE|fpos_t|size_t|_IOFBF|_IOLBF|_IONBF|BUFSIZ|FOPEN_MAX|L_tmpnam|SEEK_CUR|SEEK_END|SEEK_SET)'

  CSTDLIB = '(atof|atoi|atol|strtod|strtol|strtoul|rand|srand|calloc|free|malloc|realloc|abort|atexit|exit|getenv|system|bsearch|qsort|abs|div|labs|ldiv|mblen|mbtowc|wctomb|mbstowcs|wcstombs)'

  ALGORITHM = '(for_each|find|find_if|find_end|find_first_of|adjacent_find|count|count_if|mismatch|equal|search|search_n|copy|copy_backward|swap|swap_ranges|iter_swap|transform|replace|replace_if|replace_copy|replace_copy_if|fill|fill_n|generate|generate_n|remove|remove_if|remove_copy|remove_copy_if|unique|unique_copy|reverse|reverse_copy|rotate|rotate_copy|random_shuffle|partition|stable_partition|sort|stable_sort|partial_sort|partial_sort_copy|nth_element|lower_bound|upper_bound|equal_range|binary_search|merge|inplace_merge|includes|set_union|set_intersection|set_difference|set_symmetric_dif|push_heap|pop_heap|make_heap|sort_heap|min|max|min_element|max_element)'

  IOMANIP ='(setprecision|setfill|setw|fixed|scientific)' 
  IOSTREAM = '(cin|cout)'
  CLIMITS = '(CHAR_BIT|SCHAR_MIN|SCHAR_MAX|UCHAR_MAX|CHAR_MIN|CHAR_MAX|MB_LEN_MAX|SHRT_MIN|SHRT_MAX|USHRT_MAX|INT_MIN|INT_MAX|UINT_MAX|LONG_MIN|LONG_MAX|ULONG_MAX)'

  def self.up
    Language.find_by_name("C++").solutions.valuable.notcompiled.each do |solution|
      `sed -i 's/include</include </' #{solution.source.path}`
#      unless `ack-grep '#{CSTRING}' #{solution.source.path}`.empty? 
#        if `ack-grep '(<cstring>|<string.h>)' #{solution.source.path}`.empty?
#          `sed -i '1 i #include <cstring>' #{solution.source.path}`
#        end
#      end

#      unless `ack-grep '#{CSTDIO}' #{solution.source.path}`.empty? 
#        if `ack-grep '(<cstdio>|<stdio.h>)' #{solution.source.path}`.empty?
#          `sed -i '1 i #include <cstdio>' #{solution.source.path}`
#        end
#      end

#      system('sed -i "s/<iostream.h>/<iostream>\nusing namespace std;/" ' + solution.source.path)
#      system('sed -i "s/\"iostream.h\"/<iostream>\nusing namespace std;/" ' + solution.source.path)

#      if solution.junk =~ /#{IOSTREAM}’ was not declared/
#          `sed -i '1 i #include <iostream>\nusing namespace std;' #{solution.source.path}`
#      end

#      if solution.junk =~ /#{CSTDLIB}’ was not declared/
#          `sed -i '1 i #include <cstdlib>' #{solution.source.path}`          
#      end
      if solution.junk =~ /#{CLIMITS}’ was not declared/
          `sed -i '1 i #include <climits>' #{solution.source.path}`          
      end
#
#      if solution.junk =~ /#{ALGORITHM}’ was not declared/
#          `sed -i '1 i #include <algorithm>' #{solution.source.path}`          
#      end
      
#      if solution.junk =~ /#{IOMANIP}’ was not declared/
#          if `ack-grep 'iomanip.h' #{solution.source.path}`.empty?
#            `sed -i '1 i #include <iomanip>' #{solution.source.path}`
#          else
#            `sed -i 's/<iomanip.h>/<iomanip>/' #{solution.source.path}`
#          end
#      end

#      if solution.junk =~ /fstream\.h: No such file/
#        `sed -i 's/<fstream.h>/<fstream>/' #{solution.source.path}`
#      end
#      if solution.junk =~ /ostream\.h: No such file/
#        `sed -i 's/<ostream.h>/<ostream>/' #{solution.source.path}`
#      end
#      if solution.junk =~ /istream\.h: No such file/
#        `sed -i 's/<istream.h>/<istream>/' #{solution.source.path}`
#      end
#      unless `ack-grep '<complex.h>' #{solution.source.path}`.empty?
#        `sed -i 's/<complex.h>/<complex>/' #{solution.source.path}`
#      end
#
#      if solution.junk =~ /vector\.h: No such file/
#        `sed -i 's/<vector.h>/<vector>/' #{solution.source.path}`
#      end

#      if solution.junk =~ /is ambiguous/
#        `sed -i '/using namespace std/d' #{solution.source.path}`
#        `sed -i 's/cin/std::cin/' #{solution.source.path}`
#        `sed -i 's/cout/std::cout/' #{solution.source.path}`
#        `sed -i 's/endl/std::endl/' #{solution.source.path}`
#      end

#      if solution.junk =~ /expected constructor, destructor, or type conversion before ‘<’ token/
#        `sed -i '1 i using namespace std;' #{solution.source.path}`
#      end

#      if solution.junk =~ /hash_map\.h: No such file/
#        `sed -i 's/hash_map.h/map/' #{solution.source.path}`
#        `sed -i 's/hash_map/map/' #{solution.source.path}`
#      end
    end

  end

  def self.down
  end
end
