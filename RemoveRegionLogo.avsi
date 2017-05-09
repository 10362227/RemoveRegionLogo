
# ��Ҫ�����ڸǲ�͸����logo��
# ԭ����ȡlogo������α߽��ͼ����logo�������Ľ���������䣬���ڸ�logo����

# ��;ͬVirtualdub��RegionRemove.vdf��
# �����������ǣ��� ʹ��ԭ��avisynth�ű�ʵ�֡�֧��YV12ɫ�ʿռ䡣
#               �� ���ܿ�����Ƿȱһ�㣬��������һ������

# ����˵��
# x, y, width, height ��logo��������ꡣ
#               �ɽ���aviutl��logoscan���ȷ�����ꡣ
# start,end��logo���ֵ�֡���䡣
#               Ĭ��start=0,end=0����ʾȡȫ��֡��
# fade, fade_in, fade_out ���ڲ������뽥����Ч����
#               �����ӵĽ���֡����������ȷ��logo���ֵ�֮ǰ��֮�����㹻��֡���н��䡣
#               Ĭ��fade_in=fade=0��fade_out=fade=0
# soft_edges �Ƿ�������Ե��
#               ��Ҫ���ø��logo���������Ӧ��������Լ8�����Ա�֤logo����ȫ���ǡ�

# author��mikey
# qhzq88@gmail.com
# �����Ŷӣ��д廨����Ļ��
# last modified : 2017.05.09

function RemoveRegionLogo(clip src, 
\ int x, int y, int width, int height, 
\ int "start", int "end", int "fade", int "fade_in", int "fade_out", 
\ bool "ignore_top", bool "ignore_bottom", bool "ignore_left", bool "ignore_right",
\ bool "soft_edges")
{

start= Default(start, 0)
end= Default(end, 0)

fade     = Default(fade, 0)
fade_in  = start!=0 ? Default(fade_in, fade) : 0
fade_out = end!=0 ? Default(fade_out, fade) : 0

ignore_top    = Default(ignore_top, false)
ignore_bottom = Default(ignore_bottom, false)
ignore_left   = Default(ignore_left, false)
ignore_right  = Default(ignore_right, false)

soft_edges = Default(soft_edges, false)


Assert(start>=0,"start must >= 0")
end = end<0 ? start + (-end) -1 : end

bit = 2

trim_start = start - fade_in
trim_end = end + fade_out

logo_src = src.Trim(trim_start, trim_end)
empty = BlankClip(src, color=$ffffff, pixel_type="RGB32")


top    = ignore_top ? empty : logo_src.Crop(x,y,width,bit)
bottom = ignore_bottom ? empty : logo_src.Crop(x,y+height,width,bit)
piece1 = ignore_top&&ignore_bottom ? empty \
    : ignore_top==false&&ignore_bottom==false ? StackVertical(top, bottom) \
    : ignore_top ? bottom \
    : top

left   = ignore_left ? empty : logo_src.Crop(x,y,bit,height)
right  = ignore_right ? empty : logo_src.Crop(x+width,y,bit,height)
piece2 = ignore_left&&ignore_right ? empty \
    : ignore_left==false&&ignore_right==false ? StackHorizontal(left,right) \
    : ignore_left ? right \
    : left


box1 = ignore_top==false||ignore_bottom==false ? piece1.PointResize(width,2*bit).Blur(1.0).BilinearResize(width,height) : empty
box2 = ignore_left==false||ignore_right==false ? piece2.PointResize(2*bit,height).Blur(1.0).BilinearResize(width,height) : empty

delogo = ignore_top&&ignore_bottom ? box2 \
    : ignore_left&&ignore_right ? box1 \
    : Merge(box1,box2)


mask = BlankClip(delogo, color=$ffffff, pixel_type="RGB32")

mask = soft_edges ? mask.AddBorders(4, 4, 4, 4, color=$000000)
\.Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50).Blur(1.50)
\.Crop(2,2,-2,-2).BilinearResize(width,height)
\:mask

mask = fade_out==0 ? mask : mask.FadeOut(fade_out, color=$000000)
mask = fade_in==0? mask : mask.FadeIn(fade_in, color=$000000)

delogo_clip = logo_src.Overlay(delogo,x,y,mask)

new_clip = delogo_clip
new_clip = trim_start>0 ? src.Trim(0, -trim_start) + new_clip : new_clip
new_clip = trim_start+logo_src.FrameCount != src.FrameCount() ? new_clip + src.Trim(trim_start+logo_src.FrameCount, 0) : new_clip

Assert(src.FrameCount() == new_clip.FrameCount() , "internal error. frame count not equal.")

return new_clip

}


# example
#~ RemoveRegionLogo(244,36,948,158)
#~ RemoveRegionLogo(462,114,510,62, 955,1554, fade=20)
#~ RemoveRegionLogo(270,52,910,62, 955,1554, fade=20, soft_edges=true)