using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System.Configuration;
using System.Data;
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

namespace PodSproutFM
{
    /// <summary>
    /// Логика взаимодействия для Login.xaml
    /// </summary>
    public partial class Login : Page
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";

        public Login()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        private void BtnLogin_Click(object sender, RoutedEventArgs e)
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.LOGINUSER";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PUSERLOGIN", OracleDbType.Varchar2, 30).Value = userLogin.Text.Trim();
            cmd.Parameters.Add("PUSERPASSWORD", OracleDbType.Varchar2, 30).Value = userPassword.Password.Trim();
            cmd.Parameters.Add("OUSERID", OracleDbType.Int32, 10);
            cmd.Parameters["OUSERID"].Direction = ParameterDirection.Output;
            cmd.Parameters.Add("OUSERLOGIN", OracleDbType.Varchar2, 30);
            cmd.Parameters["OUSERLOGIN"].Direction = ParameterDirection.Output;
            cmd.Parameters.Add("OUSERROLE", OracleDbType.Varchar2, 30);
            cmd.Parameters["OUSERROLE"].Direction = ParameterDirection.Output;
            try
            {
                cmd.ExecuteNonQuery();
                string user = Convert.ToString(cmd.Parameters["OUSERLOGIN"].Value);
                string role = Convert.ToString(cmd.Parameters["OUSERROLE"].Value);
                int id = Convert.ToInt32((decimal)(OracleDecimal)(cmd.Parameters["OUSERID"].Value));
                DataWorker.CurrentUserLogin = user;
                DataWorker.CurrentUserRole = role;
                DataWorker.CurrentUserId = id;
                this.NavigationService.Navigate(new Uri("Home.xaml", UriKind.Relative));
            }
            catch (Exception exc)
            {
                MessageBox.Show("Неверный логин или пароль!");
            }
            con.Close();
        }
        private void BtnToRegistration_Click(object sender, RoutedEventArgs e)
        {
            this.NavigationService.Navigate(new Uri("Register.xaml", UriKind.Relative));
        }
    }
}