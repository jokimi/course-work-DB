﻿#pragma checksum "..\..\..\ExtraWindows\UpdateTopic.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "B3E1E105370F0DF2018CCACBF3D2DE6E0D5EEF0DFC796FF627E7266302229063"
//------------------------------------------------------------------------------
// <auto-generated>
//     Этот код создан программой.
//     Исполняемая версия:4.0.30319.42000
//
//     Изменения в этом файле могут привести к неправильной работе и будут потеряны в случае
//     повторной генерации кода.
// </auto-generated>
//------------------------------------------------------------------------------

using PodSproutFM.ExtraWindows;
using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;


namespace PodSproutFM.ExtraWindows {
    
    
    /// <summary>
    /// UpdateTopic
    /// </summary>
    public partial class UpdateTopic : System.Windows.Window, System.Windows.Markup.IComponentConnector, System.Windows.Markup.IStyleConnector {
        
        
        #line 90 "..\..\..\ExtraWindows\UpdateTopic.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBlock thisTopicName;
        
        #line default
        #line hidden
        
        
        #line 93 "..\..\..\ExtraWindows\UpdateTopic.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBlock narratorName;
        
        #line default
        #line hidden
        
        
        #line 96 "..\..\..\ExtraWindows\UpdateTopic.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox topicName;
        
        #line default
        #line hidden
        
        
        #line 98 "..\..\..\ExtraWindows\UpdateTopic.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox topicYear;
        
        #line default
        #line hidden
        
        
        #line 99 "..\..\..\ExtraWindows\UpdateTopic.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button addBtn;
        
        #line default
        #line hidden
        
        
        #line 105 "..\..\..\ExtraWindows\UpdateTopic.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button closeBtn;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/PodSproutFM;component/extrawindows/updatetopic.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\ExtraWindows\UpdateTopic.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 3:
            this.thisTopicName = ((System.Windows.Controls.TextBlock)(target));
            return;
            case 4:
            this.narratorName = ((System.Windows.Controls.TextBlock)(target));
            return;
            case 5:
            this.topicName = ((System.Windows.Controls.TextBox)(target));
            return;
            case 6:
            this.topicYear = ((System.Windows.Controls.TextBox)(target));
            
            #line 98 "..\..\..\ExtraWindows\UpdateTopic.xaml"
            this.topicYear.PreviewTextInput += new System.Windows.Input.TextCompositionEventHandler(this.TopicPreviewTextInput);
            
            #line default
            #line hidden
            return;
            case 7:
            this.addBtn = ((System.Windows.Controls.Button)(target));
            
            #line 99 "..\..\..\ExtraWindows\UpdateTopic.xaml"
            this.addBtn.Click += new System.Windows.RoutedEventHandler(this.AddBtn_Click);
            
            #line default
            #line hidden
            return;
            case 8:
            this.closeBtn = ((System.Windows.Controls.Button)(target));
            
            #line 105 "..\..\..\ExtraWindows\UpdateTopic.xaml"
            this.closeBtn.Click += new System.Windows.RoutedEventHandler(this.CloseBtn_Click);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        void System.Windows.Markup.IStyleConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            
            #line 46 "..\..\..\ExtraWindows\UpdateTopic.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.BtnMinimize_Click);
            
            #line default
            #line hidden
            break;
            case 2:
            
            #line 52 "..\..\..\ExtraWindows\UpdateTopic.xaml"
            ((System.Windows.Controls.Button)(target)).Click += new System.Windows.RoutedEventHandler(this.BtnClose_Click);
            
            #line default
            #line hidden
            break;
            }
        }
    }
}

