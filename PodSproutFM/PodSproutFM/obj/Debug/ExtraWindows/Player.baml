   M S B A M L   `   `   `  ����F  BPodSproutFM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullC&clr-namespace:PodSproutFM.ExtraWindowsPodSproutFM.ExtraWindows  5   	   %    PodSproutFM.ExtraWindows.Player   5   	   R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   8local&clr-namespace:PodSproutFM.ExtraWindows     5   	   -   5          � WindowStartupLocation$  CenterScreen=�5   	    � WindowStyle$
 None=�5	   	    � AllowsTransparency .  � Title$ Player��5
   	   $	��358��6   $	��410��6%    � 	Resources 5      %   PodSproutFM.ExtraWindows.Player �� 
TargetType �� Property �� Value �� 
TargetType	 �� Padding
 ��Name   OffWhiteBrush �� CornerRadius J� Effect3  -System.Windows.Media.Effects.DropShadowEffect   ShadowDepth   Opacity J� OpacityMask !� Visual �� ElementName � RowDefinitions K� ZIndex � ColumnDefinitions  	Hoverless  
HeaderText �� Orientation ��Name  MinimizingEll  MaximizingEll  
ClosingEll �� 
StartPoint �� EndPoint  OffWhite � Color � Offset  Grey��%�  '        7   7   7  7  7  7  7  7  7  7  7  7  7  �� 5   
   "  6   .�5      ��  � �� 5      �� 5      " �6&   .R�5      �� ���#fcf0d6$	 0q�66   ._�5      � .+�5   "   �� $
 	Container��6)   8��  $ 10��6h   �� 5   "   $ 10��6)   8��  5   &     5   *   $ 0Q�6;   $	 0.5Q�6K   5   #   � 5   "    5   &   !� 5   *    66   �� $ 	Container�� 5   &   �� 5   *   $��42 �68   �� 5   *   $
��Auto �68   �� 5    *   $��* �68   .+�5"   &   � $��0��6+   $ 1��6;   ���#fcf0d6 5#   *   �� 5$   .   $
��Auto �6?   �� 5%   .   $��* �6?   �� 5&   .   $
��Auto �6?   .+�5(   *   �� 8�� ��6T   �� *MenuCommand+.��5)   .   �� $��../Images/PodSproutFM.jpg��64   5*   +   (� 5+   *   $��0��62   $��3��6B   $��0q�6V   .��5,   .   �� 8�� PodSproutFM6i   5-   +   �� 5.   *   $��2��65   $ 
Horizontal=�6E   .+�5/   .   �� $ btnMinimize��65   -   5        $��2q�5/   J   8�� .��50   2   A� 8�� 6:   51   /   �� 52   .   $ btnMaximize��65   $��2q�6J   8�� .��53   2   A� 8�� 6:   54   /   �� 55   .   $ btnClose��65   -   5        $��2 0 10 0q�55   G   8�� .��56   2   A� 8��	 6:   57   /   58   +   59   '   �� 5:   &   $��1��6-   $
��Auto��6:   $��	0 0.2 0 0q�6H   ��5;   *   �� 5<   .   $	 0,0&�6B   $	 1,0&�6S   .��5=   2   � 8 
 $	 0.0Q�6a   � 5>   2   8  $	 0.5Q�6]   � 5?   2   8  $	 1.0Q�6a   5@   /   5B   '   �� 5C   &   $��2��6-   	 6:   �� *InnerContentPaddingThickness+._�5D   *   �� #��z��6;   5E   '   5F   #   5G      5H      5I      5K      5L      5M      '  !System.Windows.Shell.WindowChrome   WindowChrome 5N        5O   
      ResizeBorderThickness$ 10q�6      CaptionHeight$ 42Q�62      GlassFrameThickness$ 0q�6E      CornerRadius$ 15��6]   .��5Q      �� ��5R   
   �� 5S        �� ImageSource$  ../Images/background.jpg��6   ! j� Stretch$! UniformToFill=�6@   ._�5U   
   � .+�5V      �� $��Center=�6   $��Center=�64   " �� TextAlignment$" Center=�6Q   .+�5W      �� #��[  6   $	 20q�6E   $��30q�6R   $ 15��6^   $	��350��6p   $	��195��6|   ._�5X      �� .+�5Y      �� -   5        # ��Name$# podcastName��5Y   $   $��PODCAST'S NAME��69   $��0 0 0 10q�6O   $��30(�6a   $��Architun)�6o   �� 5Z      $ 
Horizontal=�6%   $��Center=�6>   $
��Auto��6[   .+�5[      �� $��Диктор:��6(   $��0 0 5 0q�67   ���#6d8960  FontSizeSmall#��[ 6]   $��Architun)�6�   �� 5\      -   5        $# narratorName��5\   (   $��NARRATOR'S NAME��6>   $��0 0 0 5q�6U   #��[ 6f   $��Architun)�6�   5]      �� 5^      $ 
Horizontal=�6%   $��Center=�6>   $
��Auto��6[   .+�5_      �� $��	Тема:��6(   $��0 0 5 0q�65   ���#6d8960#��[ 6[   $��Architun)�6�   �� 5`      -   5        $# 	topicName��5`   (   $��TOPIC'S NAME��6;   $��0 0 0 20q�6O   #��[ 6a   $��Architun)�6�   5a      �� 5b      $ 
Horizontal=�6%   $��Center=�6>   $
��Auto��6[   .+�5c      �� -   5        $ 
PlayButton��5c   %   $��▶️��69   $��0 0 5 0q�6F   $��Center=�6W   $��55��6�   $��13 13 10 10q�6�   �� 5d      -   5        $ PauseButton��5d   %   $��❚❚��6:   $��0 0 5 0q�6G   $��Center=�6X   $��55��6�   $��10 13 10 10q�6�   �� 5e      -	   5        $ 
StopButton��5e   %   $��⬛️��69   $��0q�6F   $��Center=�6Q   $��55��6�   $��15 18 15 15q�6�   5f      5g      5h      �� 5i      ���#6d8960$	 0q�6.   $��Center=�6:   $	��800��6W   $��2��6c   ._�5j      �� -
   5        $ closeBtn��5j      $��
Назад��6/   $��2��6?    	 WhiteCommonButton#��[	 6L   $��Center=�6w   6�   5k      5l      5m      5n      5o      