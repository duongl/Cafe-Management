using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Sql;
using System.Data;
using QuanLyQuanCafe;
using QuanLyQuanCafe.DTOO;

namespace QuanLyQuanCafe.DAOO
{
    public class BillDAO
    {
        private static BillDAO instance;

        public static BillDAO Instance
        {
            get { if (instance == null) instance = new BillDAO(); return BillDAO.instance; }
            private set { BillDAO.instance = value; }
        }
        private BillDAO() { }
        // Thành công: bill ID
        //Thất bại: -1
        public int GetuncheckBillByTableID(int id)
        {
            DataTable data = DataProvider.Instance.ExecuteQuery("SELECT * FROM Bill WHERE idTable = " + id + " AND status = 0");
            if (data.Rows.Count > 0)
            {
                Bill bill = new Bill(data.Rows[0]);
                return bill.ID;
            }
            return -1;
        }

        public void CheckOut(int id, int discount)
        {
            string query = "UPDATE Bill SET status = 1, " + " discount = " + discount + " WHERE id = " + id;
            DataProvider.Instance.ExecuteNonQuery(query);
        }

        //Tuy Chinh Bàn
        public static void TableDrinkUpdate(int id, string status)
        {
            string query = string.Format("UPDATE TableDrink SET status = N'{0}' WHERE id = {1}", status, id);
            DataProvider.Instance.ExecuteNonQuery(query);
        }

        // chuyển bill
        public static void ChuyenBill(int idBanHienTai, int idBanCanChuyen)
        {
            //string query = string.Format("UPDATE Bill SET idTable = @idBanCanChuyen WHERE idTable = @idBanHienTai AND status = 0 ");
            //DataProvider.Instance.ExecuteNonQuery(query);
        }

        // Xóa bill
        public static void XoaBill(int id)
        {
            //string query = string.Format("DELETE FROM Bill WHERE idTable = @idBanHienTai AND status = 0 ");
            //DataProvider.Instance.ExecuteNonQuery(query);
        } 

        public void InsertBill(int id)
        {
            DataProvider.Instance.ExecuteNonQuery("exec USP_InsertBill @idTable", new object[] { id });
        }

        public int GetMaxIDBill()
        {
            try
            {
                return (int)DataProvider.Instance.ExecuteScalar("select MAX(id) from Bill");
            }
            catch
            {
                return 1;
            }
        }
    }
}
