# tools
Random tools and commands 

Excel 2016 Mac 
=TRIM(SUBSTITUTE(A2,",",", "))

=VLOOKUP(A2,Sheet2!$A$1:$B$392,2,FALSE)

=CONCATENATE(A1, "-", B1)

Set Date using wget
sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
