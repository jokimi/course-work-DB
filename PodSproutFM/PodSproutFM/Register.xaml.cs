using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
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
    /// Логика взаимодействия для Register.xaml
    /// </summary>
    public partial class Register : Page
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";

        public Register()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        private void BtnGoBack_Click(object sender, RoutedEventArgs e)
        {
            this.NavigationService.Navigate(new Uri("Login.xaml", UriKind.Relative));
        }

        private void BtnRegister_Click(object sender, RoutedEventArgs e)
        {
            if (String.IsNullOrWhiteSpace(userLogin.Text.Trim()) || String.IsNullOrWhiteSpace(userPassword.Password.Trim()) || String.IsNullOrWhiteSpace(userRepeatPassword.Password.Trim()))
            {
                MessageBox.Show("Заполните все поля!");
                return;
            }
            if (userPassword.Password.Trim() != userRepeatPassword.Password.Trim())
            {
                MessageBox.Show("Пароли не совпадают! Попробуйте ещё раз.");
                return;
            }
            try
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.REGISTERUSER";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PUSERLOGIN", OracleDbType.Varchar2, 30).Value = userLogin.Text.Trim();
                cmd.Parameters.Add("PUSERPASSWORD", OracleDbType.Varchar2, 30).Value = userPassword.Password.Trim();

                cmd.ExecuteNonQuery();
                MessageBox.Show("Пользователь успешно создан!");
                this.NavigationService.Navigate(new Uri("Login.xaml", UriKind.Relative));
            }
            catch (OracleException oracleEx)
            {
                MessageBox.Show($"Пользователь с таким именем уже существует!");
            }
            catch (Exception exc)
            {
                MessageBox.Show($"Неизвестная ошибка: {exc.Message}");
            }
            finally
            {
                con.Close();
            }
        }
    }
}