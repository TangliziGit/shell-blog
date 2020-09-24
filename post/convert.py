lines = open("2020-09-20_基础知识复习.md", 'r').readlines()
out = open("out.md", 'w')

for line in lines:
    if '#' in line:
        out.write("  \n")
    out.write(line)

