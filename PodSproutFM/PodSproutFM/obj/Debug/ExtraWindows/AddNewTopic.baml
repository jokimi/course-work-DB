   M S B A M L   `   `   `  ����F  BPodSproutFM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullC&clr-namespace:PodSproutFM.ExtraWindowsPodSproutFM.ExtraWindows  5   	   *    $PodSproutFM.ExtraWindows.AddNewTopic   5   	   R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   8local&clr-namespace:PodSproutFM.ExtraWindows     5   	   -   5          � WindowStartupLocation$  CenterScreen=�5   	    � WindowStyle$
 None=�5	   	    � AllowsTransparency .  � Title$ AddNewTopic��5
   	   $	��600��6   $	��800��6*    � 	Resources 5      *   $PodSproutFM.ExtraWindows.AddNewTopic �� 
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
   �  5V      �� 5W      �� 5X      $
��Auto �6    �� 5Y      $
��Auto �6    .+�5[      �� $��0��6   $
��Auto=�6(   $��Disabled=�6K   .��5\      �� $��Center=�6   $��Center=�68   " �� TextAlignment$" Center=�6U   .+�5]      �� #��[  6   $	 20q�6I   $��20q�6V   $ 10��6b   $	��400��6t   ._�5^      �� .+�5_      ��   FontSizeLarge#��[ 6(    	 LightPurpleBrush#��[	 6R   $��Новая тема��6�   $��0 0 0 20q�6�   $��Architun)�6�   �� 5`      $��Название:��6(    
 	GreyBrush#��[
 69     FontSizeSmall#��[ 6a   $��Architun)�6�   �� 5a      -   5        # ��Name$# 	topicName��5a   &   $��Architun)�69   �� 5b      $��Диктор:��6(   #��[
 67   #��[ 6_   $��Architun)�6�   $��0 5 0 0q�6�   �� 5c      -   5        $ ��Name$$ narratorNameCombo��5c   '   $
��0 10q�6B   $��15 0 0 0q�6P   $��0 0 0 2q�6c   $��Architun)�6}     	TealBrush#��[ 5d   #     OffBlackBrush#��[ 6L   #��[ 5e   #   $��Center=�6M   $��Center=�5f   #   $��Center=�6G   $	��Top=�5g   #   $	��360��6;   $��40��6G   $" Center=�6S   �� 5h      $��Год выпуска:��6(   #��[
 6<   #��[ 6d   $��Architun)�6�   �� 5i      -   5        $# 	topicYear��5i   &   $��Architun)�6b   � 5j       5k   "   �� 5l   &   $
��Auto �64   �� 5m   &   $��* �64   .+�5o   "   �� -   5        $ attachPhoto��5o   )   $��0��6>   $
��📸��6K   $��Center=�6X   $��Center=�6u   6�   �� 5p   "   -   5        % ��Name$% 
coverImage��5p   5   $��1��6(   $ 0��6I   $��Uniform=�6Z   $	��300��6l   5q      �� 5r      -	   5        $ addBtn��5r   %   $��Добавить��65   $��Center=�6H   6e   5s      5t      5u      5v      �� 5w      ���#6d8960$	 0q�6*   $��Center=�66   $��Bottom=�6S   $��70��6n   $	��800��6z   $��2��6�   ._�5x      �� -
   5        $ closeBtn��5x      $��
Назад��6+   $��2��6;     WhiteCommonButton#��[ 6H   $��Center=�6s   6�   5y      5z      5{      5|      