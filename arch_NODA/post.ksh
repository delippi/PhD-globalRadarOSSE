#!/bin/ksh

hr=0
groups_of=2
hrmax=168
typeset -Z3 count hr 
lst=""
grp=""
dep=""
count=1
while [[ $hr -le $hrmax ]]; do

   group=1
   str=""   
   while [[ $group -le $groups_of ]]; do 
      if [[ $group -eq $groups_of ]]; then
         if [[ $hr -ge $hrmax ]]; then
            dep=`echo $dep f$hrmax`
         else
            dep=`echo $dep f$hr`
         fi
      fi 
      if [[ $group -eq 1  ]]; then
         str="f$hr"
      elif [[ $hr -ge $hrmax  ]]; then
            str=`echo ${str}_f$hrmax`
            lst=`echo $lst $str`
            grp=`echo $grp $count`
            break 2 
      else
         str=`echo ${str}_f$hr`
      fi
      (( group=group+1 ))
      (( hr=hr+1 ))
   done
   lst=`echo $lst $str`
   grp=`echo $grp $count`
   (( count=count+1 ))

done


echo "<var name=\"grp\">$grp</var>"
echo ""
echo "<var name=\"dep\">$dep</var>"
echo ""
echo "<var name=\"lst\">$lst</var>"


