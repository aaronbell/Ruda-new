
#!/bin/sh
set -e


echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m Ruda.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Ruda.designspace -i -o otf --output-dir ../fonts/otf/


echo "Generating VFs"
mkdir -p ../fonts/vf
fontmake -m Ruda.designspace -o variable --output-path ../fonts/vf/Ruda[wght].ttf


rm -rf master_ufo/ instance_ufo/ instance_ufos/*



echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	ttfautohint $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done

for ttf in $ttfs
do
	gftools fix-hinting $ttf;
	#mv "$ttf.fix" $ttf;
done



vfs=$(ls ../fonts/vf/*\[wght\].ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	ttfautohint --stem-width-mode nnn $vf "$vf.fix";
	mv "$vf.fix" $vf;
done




echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;

echo "Dropping MVAR"
for vf in $vfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/vf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done



echo "Fixing Hinting"
FONTSVF=$(ls ../fonts/vf/*.ttf)
for font in $FONTSVF
do
  gftools fix-hinting $font
  mv $font.fix $font;
done

