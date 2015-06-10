function           RGB=Opponent_Tri_RGB(double_response)
%2011.11.23
%���ܣ�����˫�׿����õ�����Ӧ��ת����RGBͨ�����й۲죬�������ڼ����ͼ���γ���ϵ���ܿ��ó���Ϣ
[a b c]=size(double_response);
RGB=zeros(a,b,c);
for i=1:a
    for j=1:b
       
            
             RGB(i,j,1)=0.7071*double_response(i,j,1)+0.4082*double_response(i,j,2)+0.5774*double_response(i,j,3);
             RGB(i,j,2)=-0.7071*double_response(i,j,1)+0.4082*double_response(i,j,2)+0.5774*double_response(i,j,3);
             RGB(i,j,3)=0*double_response(i,j,1)-0.8165*double_response(i,j,2)+0.5774*double_response(i,j,3);
            
   end
end