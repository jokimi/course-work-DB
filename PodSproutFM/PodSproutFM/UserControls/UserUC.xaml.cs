using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PodSproutFM.UserControls
{
    /// <summary>
    /// Логика взаимодействия для UserUC.xaml
    /// </summary>
    public partial class UserUC : UserControl
    {
        public UserUC()
        {
            InitializeComponent();
        }
        public UserUC(Int32 id, string log, string pass, string role)
        {
            InitializeComponent();
            blockId.Text = id.ToString();
            blockRole.Text = role;
            blockLog.Text = log;
            blockPass.Text = pass;
        }
    }
}