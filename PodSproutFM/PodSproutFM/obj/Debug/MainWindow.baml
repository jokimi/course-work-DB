   M S B A M L   `   `   `  ����F  BPodSproutFM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null)clr-namespace:PodSproutFMPodSproutFM  5   	       PodSproutFM.MainWindow   5   	   R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   +localclr-namespace:PodSproutFM     5   	     � WindowStartupLocation$  CenterScreen=�5   	    � WindowStyle$
 None=�5	   	    � AllowsTransparency .  � Title$ 
MainWindow��5
   	   $	��600��6   $
��1000��6)    � 	Resources 5         PodSproutFM.MainWindow �� 
TargetType �� Property �� Value �� 
TargetType	 �� Padding
 ��Name   OffWhiteBrush �� CornerRadius J� Effect3  -System.Windows.Media.Effects.DropShadowEffect   ShadowDepth   Opacity J� OpacityMask !� Visual �� ElementName � RowDefinitions K� ZIndex � ColumnDefinitions  	Hoverless  
HeaderText �� Orientation ��Name  MinimizingEll  MaximizingEll  
ClosingEll �� 
StartPoint �� EndPoint  OffWhite � Color � Offset  Grey��%�  '        7   7   7  7  7  7  7  7  7  7  7  7  7  �� 5   
   "  6   .�5      ��  � �� 5      �� 5      " �6&   .R�5      �� ���#fcf0d6$	 0q�66   ._�5      � .+�5   "   �� $
 	Container��6)   8��  $ 10��6h   �� 5   "   $ 10��6)   8��  5   &     5   *   $ 0Q�6;   $	 0.5Q�6K   5   #   � 5   "    5   &   !� 5   *    66   �� $ 	Container�� 5   &   �� 5   *   $��42 �68   �� 5   *   $
��Auto �68   �� 5   *   $��* �68   .+�5!   &   � $��0��6+   $ 1��6;   ���#fcf0d6 5"   *   �� 5#   .   $
��Auto �6?   �� 5$   .   $��* �6?   �� 5%   .   $
��Auto �6?   .+�5'   *   �� 8�� ��6T   �� *MenuCommand+.��5(   .   �� $��./Images/PodSproutFM.jpg��64   5)   +   (� 5*   *   $��0��62   $��3��6B   $��0q�6V   .��5+   .   �� 8�� PodSproutFM6i   5,   +   �� 5-   *   $��2��65   $ 
Horizontal=�6E   .+�5.   .   �� $ btnMinimize��65   -   5        $��2q�5.   J   8�� .��5/   2   A� 8�� 6:   50   /   �� 51   .   $ btnMaximize��65   $��2q�6J   8�� .��52   2   A� 8�� 6:   53   /   �� 54   .   $ btnClose��65   -   5        $��2 0 10 0q�54   G   8�� .��55   2   A� 8��	 6:   56   /   57   +   58   '   �� 59   &   $��1��6-   $
��Auto��6:   $��	0 0.2 0 0q�6H   ��5:   *   �� 5;   .   $	 0,0&�6B   $	 1,0&�6S   .��5<   2   � 8 
 $	 0.0Q�6a   � 5=   2   8  $	 0.5Q�6]   � 5>   2   8  $	 1.0Q�6a   5?   /   5A   '   �� 5B   &   $��2��6-   	 6:   �� *InnerContentPaddingThickness+._�5C   *   �� #��z��6;   5D   '   5E   #   5F      5G      5H      5J      5K      5L      '  !System.Windows.Shell.WindowChrome   WindowChrome 5M        5N   
      ResizeBorderThickness$ 10q�6      CaptionHeight$ 42Q�62      GlassFrameThickness$ 0q�6E      CornerRadius$ 15��6]   .��5P      �� ��5Q   
   �� 5R        �� ImageSource$  ./Images/background.jpg��6   ! j� Stretch$! UniformToFill=�6?   ._�5T   
   � .+�5U       � -   5        "  �Name$" 	MainFrame��5U      #  � Source$# ./Login.xaml?�6'   $  � NavigationUIVisibility$$ Hidden=�6=   5V      5W      5X      