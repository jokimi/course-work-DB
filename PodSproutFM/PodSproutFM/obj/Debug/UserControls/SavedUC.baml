   M S B A M L   `   `   `  ����F  BPodSproutFM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullC&clr-namespace:PodSproutFM.UserControlsPodSproutFM.UserControls  5      &     PodSproutFM.UserControls.SavedUC   5      R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5      R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5      Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5      @d2http://schemas.microsoft.com/expression/blend/2008     5      8local&clr-namespace:PodSproutFM.UserControls     5      .��5	      �   � RowDefinitions  5
   
   �� 5      $
��Auto �6   .+�5   
   �� $��0��6   $��10q�6    �� CornerRadius$ 10��6*    �� Padding$ 30 15q�6<      OffWhiteBrush#��[  6L   ._�5      �  � ColumnDefinitions 5      �� 5      $
��Auto �6'   �� 5      $��* �6'   �� 5      $
��Auto �6'   .+�5      �� $��0��6   $��Center=�6-   $
��0 15q�6H   .+�5      �� -   5         ��Name$ 
topicCover��5      $	��150��60   $	��150��6@   $��UniformToFill=�6O    J� Clip 5      �� 5       �� RadiusX$ 20Q�60    �� RadiusY$ 20Q�6=    �� Rect$ 0,0,150,150�6J   5      5      �� 5      $��1��6   $��Center=�6-   $��	30 0 20 0q�6H   .+�5      �� -   5        	 ��Name$	 blockPodcastName��5   .   $��35(�6    $��PODCAST'S NAME��6H   $��Architun)�6^   $��0 0 0 10q�6t   �� 5      
 �� Orientation$
 
Horizontal=�6!   .+�5      �� $��Диктор:��6$   $��0 0 5 0q�63   $��Architun)�6D   ���#6d89606Z   �� 5      -   5        $	 blockNarratorName��5   $   $��NARRATOR'S NAME��6?   $��Architun)�6V   5       �� 5!      $
 
Horizontal=�6!   .+�5"      �� $��	Тема:��6$   $��0 0 5 0q�61   $��Architun)�6B   ���#6d89606X   �� 5#      -   5        $	 blockTopicName��5#   $   $��TOPIC'S NAME��6<   $��Architun)�6P   5$      �� 5%      $
 
Horizontal=�6!   .+�5&      �� $��Год:��6$   $��0 0 5 0q�60   $��Architun)�6A   ���#6d89606W   �� 5'      -   5        $	 	blockYear��5'   $   $
��YEAR��67   $��Architun)�6C   5(      5)      �� 5*      $��2��6   $��Center=�6-   .+�5+      �� -   5        $��playPodcast��5+      $��Включить��60   {�. $y�Visible=�5,      $��0 0 0 5q�6.   $��Center=�5-      65   �� 5.      -   5        $��removePodcast��5.      $,��&Убрать из избранного��62   {�. $y�Visible=�5/      $��0 0 0 5q�6.   $��Center=�50      65   51      52      53      54      55      