   M S B A M L   `   `   `  ����F  BPodSproutFM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullC&clr-namespace:PodSproutFM.UserControlsPodSproutFM.UserControls  5      &     PodSproutFM.UserControls.TopicUC   5      R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5      R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      8local&clr-namespace:PodSproutFM.UserControls     5      .��5	      �   � RowDefinitions  5
   
   �� 5      $
��Auto �6   .+�5   
   �� $��0��6   $��10q�6    �� CornerRadius$ 10��6*    �� Padding$ 30 15q�6<      OffWhiteBrush#��[  6L   ._�5      �  � ColumnDefinitions 5      �� 5      $
��Auto �6'   �� 5      $��* �6'   �� 5      $
��Auto �6'   �� 5      $
��Auto �6'   .+�5      �� $��0��6   $��Center=�6-   $
��0 15q�6H   .+�5      �� -   5         ��Name$ 
topicCover��5      $	��150��60   $	��150��6@   $��UniformToFill=�6O    J� Clip 5      �� 5       �� RadiusX$ 20Q�60    �� RadiusY$ 20Q�6=    �� Rect$ 0,0,150,150�6J   5      5      �� 5      $��1��6   $��Center=�6-   $��	30 0 20 0q�6H   .+�5      �� -   5        	 ��Name$	 blockTopicName��5   .   $��35(�6    $��TOPIC'S NAME��6F   $��Architun)�6Z   $��0 0 0 10q�6p   �� 5      
 �� Orientation$
 
Horizontal=�6!   .+�5      �� $��Диктор:��6$   $��0 0 5 0q�63   $��Architun)�6D   ���#6d89606Z   �� 5       -   5        $	 blockNarratorName��5    $   $��NARRATOR'S NAME��6?   $��Architun)�6V   5!      �� 5"      $
 
Horizontal=�6!   .+�5#      �� $��Год выпуска:��6$   $��0 0 5 0q�68   $��Architun)�6I   ���#6d89606_   �� 5$      -   5        $	 	blockYear��5$   $   $��RELEASE DATE��67   $��Architun)�6K   5%      5&      �� 5'      $
 
Horizontal=�6   $��2��66   .+�5(      �� -   5        $��showPodcasts��5(      $��Подкасты��61   {�. $y�Visible=�6U   $��Center=�6j   $��Center=�6�   6�   5)      �� 5*      -   5         ��Name$ adminButtons��5*      $��3��63   $��20 0 0 0q�6C   $y�	Collapsed=�6U   $��Center=�6l   .+�5+      �� -   5        $��	editTopic��5+      $��Изменить��6.   {�. $y�Visible=�6R   $��0 0 0 5q�6g   6x   �� 5,      -   5        $��deleteTopic��5,      $��Удалить��60   {�. $y�Visible=�6S   $��0q�6h   6s   5-      5.      5/      50      51      