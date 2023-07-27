FILES=`find ./ -name '*.cc' -o -name "*.h"  -o -name "*.cpp"`
clang-format -style=Google -i $FILES